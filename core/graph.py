# core/graph.py — v3 relationship graph

import json
from collections import defaultdict


def build_graph(enriched, output_path):
    # Nodes: every unique entity
    nodes = {}
    edges = []

    def add_node(name, ntype):
        key = f"{ntype}:{name}"
        if key not in nodes:
            nodes[key] = {"id": key, "label": name, "type": ntype}
        return key

    for item in enriched:
        file_node = add_node(item["path"], "FILE")
        ents = item.get("entities", {})

        for person in ents.get("people", []):
            pnode = add_node(person, "PERSON")
            edges.append({
                "source": pnode,
                "target": file_node,
                "relation": "MENTIONED_IN"
            })

        for org in ents.get("orgs", []):
            onode = add_node(org, "ORG")
            edges.append({
                "source": onode,
                "target": file_node,
                "relation": "REFERENCED_IN"
            })

        for role in ents.get("roles", []):
            rnode = add_node(role, "ROLE")
            edges.append({
                "source": rnode,
                "target": file_node,
                "relation": "ROLE_IN"
            })

    # Cross-file links: people who appear in multiple documents
    person_files = defaultdict(list)
    for item in enriched:
        for person in item.get("entities", {}).get("people", []):
            person_files[person].append(item["path"])

    cross_links = []
    for person, files in person_files.items():
        if len(files) > 1:
            cross_links.append({
                "person": person,
                "appears_in": files,
                "link_strength": len(files)
            })

    graph = {
        "nodes": list(nodes.values()),
        "edges": edges,
        "cross_file_links": cross_links,
        "stats": {
            "total_nodes": len(nodes),
            "total_edges": len(edges),
            "cross_file_entities": len(cross_links)
        }
    }

    with open(f"{output_path}/graph.json", "w") as f:
        json.dump(graph, f, indent=2)

    print(f"[GRAPH] {len(nodes)} nodes, {len(edges)} edges, {len(cross_links)} cross-file links")


if __name__ == "__main__":
    import sys
    data = json.load(open(sys.argv[1]))
    build_graph(data, sys.argv[2])
