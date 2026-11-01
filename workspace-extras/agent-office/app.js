/* The scene is drawn locally. No assets, libraries, or network services required. */
'use strict';
const $ = id => document.getElementById(id);
const NS = 'http://www.w3.org/2000/svg';
const colors = ['#168879','#dc8652','#7d79b8','#548ec0','#bf708d','#94964e'];
const state = {data:null,scope:'recent',query:'',selected:null,page:0,zoom:1,paused:false,demo:false,connected:false,positions:new Map(),targets:new Map(),bots:new Map(),lastFetch:0};
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;
const CAPACITY = 8;
let rosterSignature='';
let pagerSignature='';
let fixtureTimer, pollTimer, toastTimer;

function el(tag, attrs={}, parent) {
  const n = document.createElementNS(NS,tag);
  for (const [k,v] of Object.entries(attrs)) n.setAttribute(k,String(v));
  if(parent) parent.append(n);
  return n;
}
function textAt(parent,x,y,text,attrs={}) {
  const n=el('text',{x,y,fill:'#5c7462','font-family':'-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif','font-size':11,...attrs},parent);
  n.textContent=text;return n;
}
function p(u,v,z=0){return [510+(u-v)*.76,130+(u+v)*.38-z];}
function poly(parent,points,fill,extra={}){return el('polygon',{points:points.map(a=>a.join(',')).join(' '),fill,...extra},parent);}
function surface(parent,u,v,w,d,z,fill,extra={}){return poly(parent,[p(u,v,z),p(u+w,v,z),p(u+w,v+d,z),p(u,v+d,z)],fill,extra);}
function box(parent,u,v,w,d,h,top,left,right,z=0){
  surface(parent,u,v,w,d,z+h,top);
  poly(parent,[p(u,v+d,z+h),p(u+w,v+d,z+h),p(u+w,v+d,z),p(u,v+d,z)],left);
  poly(parent,[p(u+w,v,z+h),p(u+w,v+d,z+h),p(u+w,v+d,z),p(u+w,v,z)],right);
}
function line(parent,a,b,stroke,width=1,extra={}){el('line',{x1:a[0],y1:a[1],x2:b[0],y2:b[1],stroke,'stroke-width':width,...extra},parent);}
function ellipse(parent,x,y,rx,ry,fill,extra={}){el('ellipse',{cx:x,cy:y,rx,ry,fill,...extra},parent);}
function roomLabel(parent,u,v,title,sub){const [x,y]=p(u,v);textAt(parent,x,y,title,{'font-size':11,'font-weight':600,'letter-spacing':2,fill:'#8a9b80','text-anchor':'middle'});if(sub)textAt(parent,x,y+16,sub,{'font-size':9,fill:'#a4ae96','text-anchor':'middle'});}
const world=$('world');
const floorLayer=el('g',{},world), backLayer=el('g',{},world), furnitureLayer=el('g',{},world), robotLayer=el('g',{},world), glassLayer=el('g',{},world);

function plant(parent,u,v,size=1){
  const [x,y]=p(u,v);const g=el('g',{transform:`translate(${x},${y}) scale(${size})`},parent);
  ellipse(g,0,2,16,7,'#6b7965',{opacity:.11});
  el('path',{d:'M-11 -15 L-8 0 Q0 7 8 0 L11 -15Z',fill:'#b6c0a9'},g);ellipse(g,0,-15,11,5,'#d9dfca');
  line(g,[0,-15],[0,-48],'#6b9c70',2);
  for(const [dx,dy,r] of [[-11,-29,-30],[10,-37,35],[-9,-45,-28],[4,-52,12]])el('ellipse',{cx:dx,cy:dy,rx:7,ry:14,fill:dx<0?'#5d956f':'#80ac7c',transform:`rotate(${r} ${dx} ${dy})`},g);
}
function desk(parent,u,v,tone='#dcb990'){
  surface(parent,u+8,v+5,112,58,0,'#b6bca5',{opacity:.12});
  box(parent,u+9,v+8,8,8,42,'#b2ad94','#a1a08b','#b9b49c');box(parent,u+107,v+8,8,8,42,'#b2ad94','#a1a08b','#b9b49c');
  box(parent,u+9,v+45,8,8,42,'#b2ad94','#a1a08b','#b9b49c');box(parent,u+107,v+45,8,8,42,'#b2ad94','#a1a08b','#b9b49c');
  box(parent,u,v,125,65,6,tone,'#c09b73','#caa67c',42);
  const [x,y]=p(u+69,v+17,48);
  el('path',{d:`M${x-27},${y-38} l48,24 v31 l-48,-24z`,fill:'#405e54',stroke:'#334c43','stroke-width':2,'stroke-linejoin':'round'},parent);
  el('path',{d:`M${x-23},${y-32} l40,20 v23 l-40,-20z`,fill:'#203d37'},parent);
  for(let i=0;i<4;i++)line(parent,[x-18,y-23+i*4],[x-4+(i%2)*12,y-16+i*4+(i%2)*6],i===0?'#89c6a3':'#598f79',1.5);
  line(parent,[x-3,y+4],[x-3,y+14],'#405e54',3);surface(parent,u+57,v+26,20,15,49,'#49685b');
  surface(parent,u+38,v+43,43,14,49,'#e9dcc2');
  for(let k=0;k<3;k++)line(parent,p(u+42,v+46+k*3,49.3),p(u+76,v+46+k*3,49.3),'#c0af94',.8);
  const [cx,cy]=p(u+106,v+37,49);el('path',{d:`M${cx-4},${cy-9}v8q5 5 10 0v-8z`,fill:'#f7f5e9'},parent);ellipse(parent,cx+1,cy-9,5,2.5,'#d3c8ad');
  // A rolling chair on the aisle side of each desk.
  box(parent,u+48,v+81,39,34,8,'#729382','#557566','#5d7d6b',16);
  box(parent,u+48,v+107,39,6,29,'#7a9c89','#577b67','#668b76',17);
  line(parent,p(u+68,v+98,16),p(u+68,v+98,0),'#536b5a',3);
}
function lounge(parent){
  surface(parent,55,415,255,160,1,'#e1e5ce',{rx:10});
  // Two soft sage sofas.
  for(const [u,v] of [[70,442],[200,510]]){
    box(parent,u,v,100,45,12,'#94aaa0','#748f7f','#7c9786',8);
    box(parent,u,v,100,10,34,'#9bb4a4','#7e9c87','#86a18f',10);
    box(parent,u,v,9,45,25,'#a3baa8','#809b85','#8aa390',8);
    box(parent,u+91,v,9,45,25,'#a3baa8','#809b85','#8aa390',8);
    for(let i=0;i<2;i++)surface(parent,u+12+i*38,v+14,35,26,22,'#b1c2ad');
  }
  box(parent,150,503,58,43,6,'#e1c69c','#c7a67d','#d1b287',22);
  surface(parent,160,514,18,13,29,'#f4f1dc');
  const [x,y]=p(190,522,29);ellipse(parent,x,y-3,4,2,'#b8a582');el('path',{d:`M${x-4},${y-3}v6q4 4 8 0v-6`,fill:'#faf8e8'},parent);
  roomLabel(parent,194,606,'THE LOUNGE','A well-earned recharge');
  plant(parent,40,552,.9);plant(parent,325,565,1.05);
}
function drawRoom(){
  // Ground shadow, foundation and parquet floor.
  surface(floorLayer,10,10,820,610,-22,'#2c4b39',{opacity:.12,filter:'url(#softShadow)'});
  box(floorLayer,0,0,820,610,15,'#edeadb','#cfcebb','#d9d6c4',-15);
  surface(floorLayer,8,8,804,594,1,'#f4f0e3');
  for(let u=0;u<=820;u+=70)line(floorLayer,p(u,0,2),p(u,610,2),'#e0dfcc',.8);
  for(let v=0;v<=610;v+=70)line(floorLayer,p(0,v,2),p(820,v,2),'#e0dfcc',.8);
  // The two cutaway walls retain a clear view of the office.
  poly(backLayer,[p(0,0,0),p(820,0,0),p(820,0,105),p(0,0,105)],'#e1e6d7');
  poly(backLayer,[p(0,0,0),p(0,610,0),p(0,610,105),p(0,0,105)],'#e9ebdd');
  line(backLayer,p(0,0,105),p(820,0,105),'#f9faf0',5);line(backLayer,p(0,0,105),p(0,610,105),'#f9faf0',5);
  line(backLayer,p(0,0,5),p(820,0,5),'#cbd5c1',5);line(backLayer,p(0,0,5),p(0,610,5),'#d4dbc7',5);
  // Three long windows with a hazy green world beyond them.
  for(let i=0;i<3;i++){
    const v=65+i*120;
    poly(backLayer,[p(0,v,36),p(0,v+94,36),p(0,v+94,88),p(0,v,88)],'#b7d4c6',{stroke:'#f8f8ee','stroke-width':5});
    line(backLayer,p(0,v+47,36),p(0,v+47,88),'#f5f5e9',3);
    line(backLayer,p(0,v,62),p(0,v+94,62),'#f3f5e8',2);
    poly(floorLayer,[p(0,v,2),p(0,v+90,2),p(190,v+180,2),p(190,v+95,2)],'#ffffe9',{opacity:.44});
  }
  // Pinboard in the back wall.
  poly(backLayer,[p(170,0,35),p(310,0,35),p(310,0,85),p(170,0,85)],'#c6c9ac',{stroke:'#a9b498','stroke-width':3});
  for(const [u,z,c] of [[187,70,'#f4e3a6'],[226,66,'#e6c4a2'],[270,70,'#dbe7cd'],[203,47,'#f2e7c4'],[252,45,'#cfe0d1']])poly(backLayer,[p(u,0,z),p(u+22,0,z),p(u+22,0,z-17),p(u,0,z-17)],c);
  // Dedicated collaboration room and a wide door in its glass divider.
  surface(floorLayer,505,25,290,260,3,'#e1e9dd');
  for(let u=520;u<790;u+=25)line(floorLayer,p(u,25,4),p(u,285,4),'#d5e0d0',.8);
  // Wall-mounted display.
  poly(backLayer,[p(615,0,38),p(745,0,38),p(745,0,91),p(615,0,91)],'#476959',{stroke:'#385747','stroke-width':4});
  poly(backLayer,[p(624,0,47),p(736,0,47),p(736,0,83),p(624,0,83)],'#709786');
  const screen=p(680,0,64);textAt(backLayer,screen[0],screen[1],'LET’S FIGURE IT OUT',{'font-size':7,fill:'#eef4e7','text-anchor':'middle',transform:`rotate(26.565 ${screen[0]} ${screen[1]})`});
  // Conference table and its chairs.
  for(const [u,v] of [[576,87],[652,87],[728,87],[576,219],[652,219],[728,219]]){
    box(furnitureLayer,u,v,32,28,7,'#b49b7b','#927d65','#a38b6c',15);
    box(furnitureLayer,u,v+(v<150?0:23),32,5,20,'#bda98b','#a08a70','#ad987b',16);
  }
  box(furnitureLayer,592,137,7,7,36,'#aba990','#9b9d87','#a4a08a');box(furnitureLayer,725,178,7,7,36,'#aba990','#9b9d87','#a4a08a');
  box(furnitureLayer,565,124,193,82,8,'#e4c49a','#cba67c','#d5b187',36);
  surface(furnitureLayer,614,151,46,25,45,'#fcf8e9');surface(furnitureLayer,674,148,26,19,45,'#b1c6b2');
  for(const [u,v] of [[590,148],[725,178]]){const [x,y]=p(u,v,46);ellipse(furnitureLayer,x,y,4,2,'#c0a27e');el('path',{d:`M${x-4},${y-1}v7q4 3 8 0v-7`,fill:'#faf6e5'},furnitureLayer);}
  roomLabel(furnitureLayer,670,312,'MEETING ROOM','Where ideas connect');
  // Divider: a broad opening leaves a natural path to the table.
  for(const [v,d] of [[25,85],[207,78]]){
    poly(glassLayer,[p(505,v,3),p(505,v+d,3),p(505,v+d,86),p(505,v,86)],'url(#glass)',{stroke:'#9dbca8','stroke-width':1.5});
    line(glassLayer,p(505,v,87),p(505,v+d,87),'#a5c3af',3);
  }
  for(const v of [25,110,207,285])line(glassLayer,p(505,v,3),p(505,v,87),'#9bbda6',2);
  // Two rows of desks in the main studio.
  for(const [u,v] of [[85,100],[285,100],[85,280],[285,280]])desk(furnitureLayer,u,v);
  roomLabel(furnitureLayer,250,74,'THE WORKSHOP');
  lounge(furnitureLayer);
  // Research and test lab: terminal desks, server rack, and reference shelves.
  surface(floorLayer,530,380,255,190,2,'#e8e7d8');
  desk(furnitureLayer,552,416,'#c8c5aa');
  box(furnitureLayer,755,387,43,61,97,'#577767','#354f44','#49685a');
  for(let i=0;i<5;i++){
    const [x,y]=p(780,449,83-i*15);
    el('rect',{x:x-16,y:y-5,width:28,height:9,rx:2,fill:'#2b453b',transform:`rotate(26.565 ${x} ${y})`},furnitureLayer);
    ellipse(furnitureLayer,x+6,y+1,1.6,1.6,i%2?'#ddb576':'#92c495');
  }
  roomLabel(furnitureLayer,674,591,'RESEARCH LAB','Read. Explore. Discover.');
  plant(furnitureLayer,36,30,1.1);plant(furnitureLayer,780,45,1);plant(furnitureLayer,790,558,1);
  // Coffee station by the window.
  box(furnitureLayer,14,372,44,74,43,'#dbcaa6','#c0b28f','#cbb995');
  box(furnitureLayer,21,384,27,29,30,'#576c5a','#3d5645','#4a604f',43);
  const [cx,cy]=p(48,408,64);el('rect',{x:cx-5,y:cy-9,width:9,height:12,rx:2,fill:'#b9c6a5'},furnitureLayer);ellipse(furnitureLayer,cx,cy-9,4,2,'#e2e7d2');
  const [sx,sy]=p(10,438,74);textAt(furnitureLayer,sx,sy,'COFFEE / CHARGE',{'font-size':7,fill:'#829476',transform:`rotate(-26.565 ${sx} ${sy})`});
}
drawRoom();

function robotIcon(color='#168879'){
  return `<svg viewBox="0 0 40 44" aria-hidden="true"><path d="M20 9V4" stroke="${color}" stroke-width="2"/><circle cx="20" cy="3" r="2" fill="${color}"/><rect x="7" y="10" width="26" height="20" rx="7" fill="${color}"/><rect x="11" y="14" width="18" height="10" rx="4" fill="#263e36"/><circle cx="16" cy="19" r="2" fill="#bfe8ce"/><circle cx="24" cy="19" r="2" fill="#bfe8ce"/><rect x="12" y="31" width="16" height="8" rx="3" fill="${color}"/><path d="M14 39v3m12-3v3M7 18H4m29 0h3" stroke="${color}" stroke-width="3" stroke-linecap="round"/></svg>`;
}
function createRobot(agent){
  const g=el('g',{class:'bot-hit',tabindex:0,role:'button','aria-label':`${agent.name}: ${agent.activity}`},robotLayer);
  ellipse(g,0,0,18,8,'#314b37',{opacity:.13,class:'bot-shadow'});
  ellipse(g,0,1,24,11,'none',{class:'bot-ring',stroke:'transparent','stroke-width':2});
  const body=el('g',{'data-part':'body'},g);
  el('path',{d:'M-8 -13v10h-7v-6M8 -13v10h7v-6',stroke:'#59725f','stroke-width':6,'stroke-linecap':'round',fill:'none'},body);
  el('rect',{x:-13,y:-33,width:26,height:23,rx:8,fill:agent.color,stroke:'#ffffff','stroke-width':1.6},body);
  el('rect',{x:-8,y:-29,width:16,height:11,rx:4,fill:'#d0e0ce'},body);
  el('circle',{cx:0,cy:-24,r:2.5,fill:'#f8f4cd'},body);
  el('path',{d:'M-16 -27l-6 11M16 -27l6 11',stroke:agent.color,'stroke-width':7,'stroke-linecap':'round',fill:'none',class:'bot-arms'},body);
  el('rect',{x:-21,y:-61,width:42,height:31,rx:10,fill:'#fbfcf0',stroke:'#c4d3bc','stroke-width':1.5},body);
  el('rect',{x:-25,y:-52,width:5,height:12,rx:2,fill:agent.color},body);el('rect',{x:20,y:-52,width:5,height:12,rx:2,fill:agent.color},body);
  el('rect',{x:-16,y:-56,width:32,height:19,rx:7,fill:'#2f4940'},body);
  for(const x of [-7,7])el('rect',{x:x-2.5,y:-49,width:5,height:6,rx:2.5,fill:'#b3ebcf',class:'bot-eye'},body);
  line(body,[0,-61],[0,-69],agent.color,2);ellipse(body,0,-71,3,3,agent.color);
  const bubble=el('g',{'data-part':'bubble'},g);
  el('rect',{x:12,y:-92,width:35,height:22,rx:8,fill:'#fffdf3',stroke:'#d8dfcb'},bubble);
  el('path',{d:'M19 -71l-3 6 9-5',fill:'#fffdf3',stroke:'#d8dfcb'},bubble);
  const bubbleText=textAt(bubble,29,-77,'',{'text-anchor':'middle','font-family':'ui-monospace,monospace','font-size':10,fill:'#739473'});
  const label=el('g',{'data-part':'label'},g);el('rect',{x:-51,y:9,width:102,height:19,rx:5,fill:'#fffdf4',stroke:'#e1e5d5',opacity:.95},label);
  textAt(label,0,22,shortName(agent),{'font-size':8,'text-anchor':'middle',fill:'#5e755d'});
  g.addEventListener('click',()=>showAgent(agent.id));g.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();showAgent(agent.id);}});
  return {g,body,bubble,bubbleText};
}
function shortName(a){const s=a.nickname||a.name;return s.length>21?s.slice(0,20)+'…':s;}
function esc(value){const n=document.createElement('span');n.textContent=String(value??'');return n.innerHTML;}
function humanTime(stamp){const seconds=Math.max(0,Math.floor(Date.now()/1000-stamp));return seconds<5?'just now':seconds<60?`${seconds}s ago`:seconds<3600?`${Math.floor(seconds/60)}m ago`:seconds<86400?`${Math.floor(seconds/3600)}h ago`:`${Math.floor(seconds/86400)}d ago`;}
function participants(){return new Set((state.data?.meetings||[]).flatMap(m=>[m.from,m.to]));}
function visibleAgents(){
  const talking=participants();
  return (state.data?.agents||[]).filter(a=>(state.scope==='all'||a.active||talking.has(a.id)||(state.scope==='recent'&&a.recent))&&(!state.query||`${a.name} ${a.nickname||''} ${a.project} ${a.path}`.toLowerCase().includes(state.query)));
}
function viewStatus(a){return participants().has(a.id)?'meeting':a.status;}
const statusName={working:'Working',thinking:'Thinking',reading:'Research',meeting:'Talking',idle:'Standby',waiting:'Input',unknown:'Uncertain',error:'Error'};
function render(){
  if(!state.data)return;
  const agents=visibleAgents(),talking=participants();
  const roster=$('roster');
  $('crewCount').textContent=agents.length;
  $('workCount').textContent=agents.filter(a=>a.active&&['working','thinking','reading'].includes(a.status)&&!talking.has(a.id)).length;
  $('meetCount').textContent=agents.filter(a=>talking.has(a.id)).length;
  $('idleCount').textContent=agents.filter(a=>a.status==='idle'&&!talking.has(a.id)).length;
  $('attentionCount').textContent=agents.filter(a=>['waiting','unknown','error'].includes(a.status)&&!talking.has(a.id)).length;
  const signature=JSON.stringify([state.selected,agents.map(a=>[a.id,a.name,a.activity,viewStatus(a)])]);
  if(signature!==rosterSignature){
  rosterSignature=signature;roster.replaceChildren();
  for(const a of agents){
    const status=viewStatus(a),button=document.createElement('button');
    button.className='agent-card'+(state.selected===a.id?' is-selected':'');
    button.innerHTML=`<span class="avatar" style="--avatar-bg:${a.color}14">${robotIcon(a.color)}<i class="status-dot" style="background:${status==='meeting'?'#d88851':a.active?a.color:'#9eac92'}"></i></span><span class="agent-info"><strong>${esc(a.name)}</strong><p>${esc(status==='meeting'?'Exchanging ideas':a.activity)}</p></span><span class="status-label ${status}">${statusName[status]||status}</span>`;
    button.title=a.name;button.addEventListener('click',()=>showAgent(a.id));roster.append(button);
  }
  if(!agents.length){const message=document.createElement('p');message.className='empty-list';message.textContent=state.query?'No agents match your search.':state.scope==='active'?'No agents are working right now. Enjoy the quiet.':'No recent agents. Switch to All to see earlier tasks.';roster.append(message);}
  }
  const pages=Math.max(1,Math.ceil(agents.length/CAPACITY));state.page=Math.min(state.page,pages-1);
  const priority=a=>talking.has(a.id)?2:a.active?1:0;
  const pageAgents=[...agents].sort((a,b)=>priority(b)-priority(a)).slice(state.page*CAPACITY,(state.page+1)*CAPACITY);
  const pageIds=new Set(pageAgents.map(a=>a.id));
  for(const [id,b] of state.bots)if(!pageIds.has(id)){b.g.remove();state.bots.delete(id);state.targets.delete(id);state.positions.delete(id);}
  let workIndex=0,restIndex=0,meetingIndex=0,labIndex=0,waitIndex=0;
  const deskSpots=[[150,200],[350,200],[150,380],[350,380]];
  for(const a of pageAgents){
    let target;const s=viewStatus(a);
    if(s==='meeting'){
      const i=meetingIndex++;target=[574+(i%4)*53,i%8<4?99:233];if(i>=8)target=[778,116+(i-8)*34];
    }else if(s==='reading'){
      const i=labIndex++;target=[595+(i%3)*56,511+Math.floor(i/3)*48];
    }else if(s==='idle'){
      const i=restIndex++;target=[75+(i%3)*90,460+Math.floor(i/3)*65];
    }else if(s==='waiting'||s==='unknown'||s==='error'){
      const i=waitIndex++;target=[430+(i%2)*45,420+Math.floor(i/2)*45];
    }else{
      const i=workIndex++;target=deskSpots[i%4].map((n,k)=>n+(i>=4?(k?Math.floor(i/4)*39:40):0));
    }
    const oldTarget=state.targets.get(a.id);state.targets.set(a.id,target);
    if(!state.positions.has(a.id))state.positions.set(a.id,{u:target[0],v:target[1],waypoint:null});
    else if(oldTarget&&(oldTarget[0]!==target[0]||oldTarget[1]!==target[1])){
      // Route across the open aisle and through the meeting-room doorway.
      const current=state.positions.get(a.id);current.waypoint=[470,160];
    }
    if(!state.bots.has(a.id))state.bots.set(a.id,createRobot(a));
    const b=state.bots.get(a.id);
    b.bubbleText.textContent=s==='meeting'?'•••':s==='idle'?'z z':s==='reading'?'⌕':s==='thinking'?'···':s==='waiting'?'?':s==='unknown'?'?':s==='error'?'!':'</>';
    b.bubble.setAttribute('opacity',s==='idle'?'.55':'1');
    b.g.setAttribute('aria-label',`${a.name}: ${s==='meeting'?'Exchanging messages':a.activity}`);
  }
  $('sceneEmpty').hidden=!!pageAgents.length;
  $('sceneCaption').textContent=state.demo?'FICTIONAL PREVIEW · a day in the office':`${pageAgents.length} of ${agents.length} agents on this floor`;
  const newPagerSignature=`${pages}/${state.page}`;
  if(pagerSignature!==newPagerSignature){
    pagerSignature=newPagerSignature;document.querySelector('.floor-page')?.remove();
    if(pages>1){const pager=document.createElement('div');pager.className='floor-page';pager.innerHTML=`<button aria-label="Previous floor">‹</button><span>FLOOR ${state.page+1} / ${pages}</span><button aria-label="Next floor">›</button>`;pager.children[0].onclick=()=>{state.page=(state.page+pages-1)%pages;render();};pager.children[2].onclick=()=>{state.page=(state.page+1)%pages;render();};$('sceneWrap').append(pager);}
  }
  $('officeNote').textContent=state.demo?'Fictional preview · watch agents move between rooms.':'Real activity, read locally. Every robot has a task.';
  renderFeed();renderMeeting();
}
function renderFeed(){
  const feed=$('activityFeed');feed.replaceChildren();
  const agents=new Map(state.data.agents.map(a=>[a.id,a]));
  const events=[...state.data.events,...state.data.messages.slice(0,4).map(m=>({...m,agentId:m.from,text:`Sent a message to ${agents.get(m.to)?.name||'an agent'}`}))].sort((a,b)=>b.time-a.time).slice(0,8);
  for(const event of events){
    const row=document.createElement('div');row.className='event';
    row.innerHTML=`<span class="event-mark">${event.from?'↗':'⌘'}</span><span class="event-copy"><b>${esc(agents.get(event.agentId)?.name||'Agent')}</b> · ${esc(event.text)}</span><time>${humanTime(event.time)}</time>`;feed.append(row);
  }
  if(!events.length){const e=document.createElement('p');e.className='empty-list';e.textContent='No recorded activity yet. Your next task will bring the office to life.';feed.append(e);}
}
function renderMeeting(){
  const names=new Map(state.data.agents.map(a=>[a.id,shortName(a)]));
  const meeting=state.data.meetings[0];
  if(meeting){$('meetingSummary').textContent=`${names.get(meeting.from)||'An agent'} and ${names.get(meeting.to)||'another agent'} are exchanging ideas.`;$('meetingDetails').innerHTML=`<span class="room-available"><i class="dot orange"></i> Message ${humanTime(meeting.time)}</span><span class="small-mono">${participants().size} ROBOTS TALKING</span>`;}
  else{$('meetingSummary').textContent='A quiet room, ready for the next bright idea. Agents arrive here when they exchange messages.';$('meetingDetails').innerHTML='<span class="room-available"><i class="dot green"></i> Room available</span><span class="small-mono">COLLABORATION ROOM</span>';}
}
function showAgent(id){
  const a=state.data?.agents.find(a=>a.id===id);if(!a)return;state.selected=id;
  const status=viewStatus(a);const parent=state.data.agents.find(b=>b.id===a.parentId);
  $('detailContent').innerHTML=`<span class="avatar" style="--avatar-bg:${a.color}15">${robotIcon(a.color)}</span><p class="eyebrow" style="margin-top:20px">${esc(a.role)}</p><h2>${esc(a.name)}</h2><p>${esc(status==='meeting'?'Exchanging messages with a coworker':a.activity)}</p><div class="detail-row"><span>Location</span><b>${esc(status==='meeting'?'Meeting room':status==='reading'?'Research lab':status==='idle'?'The lounge':status==='waiting'||status==='unknown'||status==='error'?'Waiting area':'The workshop')}</b></div><div class="detail-row"><span>Project</span><b>${esc(a.project)}</b></div><div class="detail-row"><span>Last activity</span><b>${humanTime(a.updated)}</b></div><div class="detail-row"><span>Agent path</span><b>${esc(a.path)}</b></div>${parent?`<div class="detail-row"><span>Working with</span><b>${esc(parent.name)}</b></div>`:''}<p class="detail-id">${esc(a.id)}</p>`;
  if(!$('details').open)$('details').showModal();render();
}
function toast(message){$('toast').textContent=message;$('toast').classList.add('show');clearTimeout(toastTimer);toastTimer=setTimeout(()=>$('toast').classList.remove('show'),3500);}

let lastFrame=0;
function animate(ms){
  const dt=Math.min((ms-lastFrame)/1000||0,.05);lastFrame=ms;
  if(!state.paused){
    const ordered=[];
    for(const [id,b] of state.bots){
      const position=state.positions.get(id),target=state.targets.get(id);if(!position||!target)continue;
      let goal=position.waypoint||target;const du=goal[0]-position.u,dv=goal[1]-position.v,dist=Math.hypot(du,dv);const moving=dist>2;
      if(reducedMotion){position.u=target[0];position.v=target[1];position.waypoint=null;}
      else if(moving){const step=Math.min(dist,dt*135);position.u+=du/dist*step;position.v+=dv/dist*step;}else if(position.waypoint)position.waypoint=null;
      const [x,y]=p(position.u,position.v,4);b.g.setAttribute('transform',`translate(${x.toFixed(2)} ${y.toFixed(2)})`);
      const s=viewStatus(state.data.agents.find(a=>a.id===id)||{});
      const bob=reducedMotion?0:moving?Math.sin(ms/75)*1.8:s==='idle'?Math.sin(ms/900)*.7:Math.sin(ms/330)*.8;
      b.body.setAttribute('transform',`translate(0 ${bob.toFixed(2)})`);
      ordered.push([y,b.g]);
    }
    ordered.sort((a,b)=>a[0]-b[0]).forEach(([,g])=>robotLayer.append(g));
  }
  requestAnimationFrame(animate);
}
requestAnimationFrame(animate);

let fetching=false;
async function poll(){
  if(state.demo||fetching)return;fetching=true;
  try{
    const response=await fetch('/api/state',{cache:'no-store',signal:AbortSignal.timeout(15000)});
    const data=await response.json();if(!response.ok)throw new Error(data.error||'Activity feed unavailable');
    if(state.demo)return;
    state.data=data;state.connected=true;state.lastFetch=Date.now();
    $('connection').className='connection';$('connectionText').textContent='Live workspace';$('syncText').textContent='Synced just now';
    $('sourceNote').textContent='Local Codex activity · read only · refreshes every 2s';render();
  }catch(error){
    if(state.demo)return;
    state.connected=false;$('connection').className='connection error';$('connectionText').textContent='Disconnected';$('syncText').textContent=state.data?'Connection lost · showing last update':'Local activity unavailable';
    $('sceneCaption').textContent='Live connection unavailable';
    $('sourceNote').textContent='Run python3 server.py, then open http://127.0.0.1:8765';
    if(!state.data){$('sceneEmpty').hidden=false;$('emptyText').textContent='Start the local server to connect your Codex agents.';$('roster').innerHTML='<p class="empty-list">Start <b>python3 server.py</b> in the agent-office folder, then open <b>http://127.0.0.1:8765</b>. Use “How it works” to try a fictional preview.</p>';}
  }finally{fetching=false;clearTimeout(pollTimer);if(!state.demo)pollTimer=setTimeout(poll,2000);}
}
function demo(){
  state.demo=true;state.page=0;state.scope='recent';state.query='';state.selected=null;
  $('search').value='';document.querySelectorAll('[data-scope]').forEach(b=>b.classList.toggle('selected',b.dataset.scope==='recent'));
  clearTimeout(pollTimer);$('aboutDialog').close();
  const now=Date.now()/1000;
  const descriptions=[['Atlas','Building the interface','working'],['Pixel','Polishing the details','working'],['Nova','Thinking through the architecture','thinking'],['Scout','Researching documentation','reading'],['Bolt','Checking the test results','working'],['Echo','Finished · ready for the next task','idle'],['Sage','Finished · ready for the next task','idle'],['Pip','Waiting for your input','waiting']];
  state.data={source:'demo',generatedAt:now,agents:descriptions.map(([name,activity,status],i)=>({id:`demo-${i}`,name,nickname:name,activity,status,color:colors[i%colors.length],project:['Interface','Research','Backend'][i%3],active:status!=='idle',recent:true,updated:now-i*7,path:i===0?'/root':`/root/${name.toLowerCase()}`,role:i===0?'Task agent':'Child agent',parentId:i===0?null:'demo-0'})),meetings:[],messages:[],events:descriptions.slice(0,5).map((a,i)=>({id:`e-${i}`,agentId:`demo-${i}`,text:a[1],time:now-i*19}))};
  $('connection').className='connection demo';$('connectionText').textContent='Fictional preview';$('syncText').textContent='Demo mode · click ↻ to return';$('sourceNote').textContent='Fictional agents · demo mode · not live activity';render();
  let phase=0;clearInterval(fixtureTimer);
  fixtureTimer=setInterval(()=>{
    if(state.paused)return;phase++;const t=Date.now()/1000;
    const pair=phase%3===1?['demo-0','demo-4']:phase%3===2?['demo-2','demo-3']:null;
    state.data.meetings=pair?[{id:`demo-message-${phase}`,from:pair[0],to:pair[1],time:t,text:'Agent message'}]:[];
    if(pair){state.data.messages.unshift(state.data.meetings[0]);state.data.messages=state.data.messages.slice(0,5);}
    render();
  },9000);
}

document.querySelectorAll('[data-scope]').forEach(b=>b.addEventListener('click',()=>{state.scope=b.dataset.scope;state.page=0;document.querySelectorAll('[data-scope]').forEach(x=>x.classList.toggle('selected',x===b));render();}));
$('search').addEventListener('input',e=>{state.query=e.target.value.toLowerCase().trim();state.page=0;render();});
function setZoom(zoom){state.zoom=Math.max(.7,Math.min(1.6,zoom));world.style.transform=`scale(${state.zoom})`;$('zoomReset').textContent=`${Math.round(state.zoom*100)}%`;}
$('zoomIn').onclick=()=>setZoom(state.zoom+.1);$('zoomOut').onclick=()=>setZoom(state.zoom-.1);$('zoomReset').onclick=()=>setZoom(1);
$('motion').onclick=()=>{state.paused=!state.paused;$('motion').setAttribute('aria-pressed',state.paused);$('motion').innerHTML=state.paused?'▶<span> Resume</span>':'Ⅱ<span> Pause</span>';document.body.classList.toggle('paused',state.paused);};
$('expand').onclick=()=>{document.querySelector('.office-panel').classList.toggle('expanded');};
document.addEventListener('keydown',e=>{if(e.key==='Escape')document.querySelector('.office-panel').classList.remove('expanded');});
$('about').onclick=()=>$('aboutDialog').showModal();$('tryDemo').onclick=demo;
document.querySelectorAll('dialog').forEach(d=>{d.querySelector('.dialog-close').onclick=()=>d.close();d.addEventListener('click',e=>{if(e.target===d){const r=d.getBoundingClientRect();if(e.clientX<r.left||e.clientX>r.right||e.clientY<r.top||e.clientY>r.bottom)d.close();}});});
$('refresh').onclick=()=>{if(state.demo){clearInterval(fixtureTimer);state.demo=false;state.data=null;state.positions.clear();for(const b of state.bots.values())b.g.remove();state.bots.clear();state.targets.clear();}poll();toast('Refreshing your workspace');};
poll();
