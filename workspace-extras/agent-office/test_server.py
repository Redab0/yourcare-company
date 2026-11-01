"""Fixture-based checks for activity truth, message windows, and read-only access."""
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path
from server import connect, snapshot


class ActivityTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name)
        with sqlite3.connect(self.home / 'state_5.sqlite') as c:
            c.executescript('''CREATE TABLE threads(id TEXT, name TEXT, agent_nickname TEXT,
                title TEXT, agent_path TEXT, source TEXT, thread_source TEXT, cwd TEXT,
                updated_at INTEGER, archived INTEGER, agent_role TEXT);
                CREATE TABLE thread_spawn_edges(child_thread_id TEXT,parent_thread_id TEXT);''')
            for id, source, archived in [('root','user',0),('child','subagent',0),('old','user',0),('guard','guardian_review',0),('archived','user',1)]:
                c.execute('INSERT INTO threads VALUES(?,?,?,?,?,?,?,?,?,?,?)',
                    (id,id,None,id,'/root/child' if id=='child' else None,'vscode',source,'/tmp/project',990 if id!='old' else 1,archived,None))
            c.execute("INSERT INTO thread_spawn_edges VALUES('child','root')")
        with sqlite3.connect(self.home / 'thread_history_1.sqlite') as c:
            c.executescript('''CREATE TABLE thread_turns(thread_id TEXT,turn_id TEXT,status TEXT,rollout_ordinal INTEGER);
                CREATE TABLE thread_items(thread_id TEXT,item_id TEXT,item_type TEXT,item_json TEXT,
                created_at_ms INTEGER,completed_at_ms INTEGER,rollout_ordinal INTEGER);''')
            for id, status in [('root','inProgress'),('child','inProgress'),('old','completed')]:
                c.execute('INSERT INTO thread_turns VALUES(?,?,?,?)',(id,'turn',status,1))
            self.add_item(c,'root','reasoning',{'type':'reasoning','content':'PRIVATE REASONING'},990)
            self.add_item(c,'child','subAgentActivity',{'type':'subAgentActivity','kind':'interacted','agentThreadId':'root','message':'PRIVATE BODY'},980)

    def tearDown(self):
        self.tmp.cleanup()

    def add_item(self,c,thread,kind,item,stamp):
        c.execute('INSERT INTO thread_items VALUES(?,?,?,?,?,?,?)',(thread,str(stamp),kind,json.dumps(item),stamp*1000,stamp*1000,stamp))

    def test_active_agents_and_exact_meeting_recipients(self):
        d = snapshot(self.home,now=1000)
        self.assertEqual({a['id'] for a in d['agents']},{'root','child','old'})
        self.assertEqual({a['id'] for a in d['agents'] if a['active']},{'root','child'})
        self.assertEqual([(m['from'],m['to']) for m in d['meetings']],[('child','root')])
        child=next(a for a in d['agents'] if a['id']=='child')
        self.assertEqual(child['rootId'],'root')
        self.assertNotIn('PRIVATE',json.dumps(d))

    def test_meeting_expires_and_stale_active_is_uncertain(self):
        self.assertFalse(snapshot(self.home,now=1025)['meetings'])
        root=next(a for a in snapshot(self.home,now=1600)['agents'] if a['id']=='root')
        self.assertEqual(root['status'],'unknown')
        self.assertTrue(root['active'])

    def test_spawn_is_not_a_message(self):
        with sqlite3.connect(self.home / 'thread_history_1.sqlite') as c:
            c.execute('DELETE FROM thread_items')
            self.add_item(c,'child','subAgentActivity',{'type':'subAgentActivity','kind':'spawned','agentThreadId':'root'},995)
        self.assertFalse(snapshot(self.home,now=1000)['meetings'])

    def test_database_connection_cannot_write(self):
        c=connect(self.home / 'state_5.sqlite')
        try:
            with self.assertRaises(sqlite3.OperationalError):
                c.execute('DELETE FROM threads')
        finally:
            c.close()

    def test_local_chat_message_uses_exact_recipient(self):
        with sqlite3.connect(self.home / 'thread_history_1.sqlite') as c:
            self.add_item(c,'root','mcpToolCall',{'type':'mcpToolCall','tool':'send_message_to_thread','status':'completed','arguments':{'threadId':'child','prompt':'PRIVATE CHAT'}},999)
        d=snapshot(self.home,now=1000)
        self.assertIn(('root','child'),[(m['from'],m['to']) for m in d['meetings']])
        self.assertNotIn('PRIVATE CHAT',json.dumps(d))

    def test_rejected_message_does_not_create_meeting(self):
        with sqlite3.connect(self.home / 'thread_history_1.sqlite') as c:
            c.execute('DELETE FROM thread_items')
            self.add_item(c,'root','mcpToolCall',{'type':'mcpToolCall','tool':'send_message_to_thread','status':'completed','arguments':{'threadId':'child'},'result':{'isError':True}},999)
        self.assertFalse(snapshot(self.home,now=1000)['meetings'])

    def test_cached_activity_updates_and_meetings_still_expire(self):
        from unittest.mock import patch
        import server
        with sqlite3.connect(self.home / 'thread_history_1.sqlite') as c:
            c.execute('CREATE TABLE thread_history_projection_state(thread_id TEXT,next_rollout_ordinal INTEGER)')
            c.executemany('INSERT INTO thread_history_projection_state VALUES(?,?)',[('root',1),('child',1),('old',1)])
        cache={}
        first=snapshot(self.home,now=1000,cache=cache)
        self.assertTrue(first['meetings'])
        with patch('server.history_rows', wraps=server.history_rows) as reader:
            second=snapshot(self.home,now=1030,cache=cache)
            self.assertFalse(second['meetings'])
            self.assertEqual(reader.call_count,3)
        with sqlite3.connect(self.home / 'thread_history_1.sqlite') as c:
            self.add_item(c,'root','fileChange',{'type':'fileChange'},1031)
            c.execute("UPDATE thread_history_projection_state SET next_rollout_ordinal=2 WHERE thread_id='root'")
        third=snapshot(self.home,now=1032,cache=cache)
        root=next(a for a in third['agents'] if a['id']=='root')
        self.assertEqual(root['activity'],'Editing project files')
        self.assertNotIn('PRIVATE',json.dumps(third))


if __name__=='__main__':
    unittest.main()
