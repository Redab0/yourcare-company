#!/usr/bin/env python3
"""Validate client wire vocabulary against backend source and peer clients.

Usage: python3 scripts/check_shared_contract.py --backend PATH --peer CLIENT_PATH
No network requests; missing or mismatched sources fail closed.
"""
import argparse
from pathlib import Path
import re


def ts_values(path, enum):
    source = path.read_text()
    match = re.search(r'export enum ' + enum + r'\s*\{([^}]+)\}', source)
    if not match:
        raise ValueError(f'Missing {enum} in {path}')
    return set(re.findall(r"=\s*['\"]([^'\"]+)['\"]", match.group(1)))


def dart_values(source, enum):
    match = re.search(r'enum ' + enum + r'\s*\{([^;]+);', source)
    if not match:
        raise ValueError(f'Missing {enum}')
    return set(re.findall(r'\b\w+\b', match.group(1)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--backend', required=True, type=Path)
    parser.add_argument('--peer', action='append', type=Path, default=[])
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    relative = Path('lib/core/api/stack_contract.dart')
    source = (root / relative).read_text()
    pairs = [
        ('OrderStatus', 'src/requests/entities/request.entity.ts', 'RequestStatus'),
        ('ServiceType', 'src/common/enums/request-type.enum.ts', 'RequestType'),
    ]
    for client, path, backend in pairs:
        actual = dart_values(source, client)
        expected = ts_values(args.backend / path, backend)
        if actual != expected:
            raise SystemExit(f'{client} contract mismatch: client={sorted(actual)}, backend={sorted(expected)}')
    for peer in args.peer:
        if (peer / relative).read_text() != source:
            raise SystemExit(f'Peer wire vocabulary differs: {peer}')
    print(f'Order/service wire contracts match backend and {len(args.peer)} peer clients.')


if __name__ == '__main__':
    main()
