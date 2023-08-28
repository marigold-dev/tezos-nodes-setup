### Brief explanation of some p2p settings and how you might adjust them:

1. connection-timeout: This is the maximum time the node will wait when trying to establish a connection with a peer. If the connection isn't established within this time, it will be aborted. You can increase this if you're experiencing a lot of connection timeouts, but be aware that a higher value could lead to slower detection of unresponsive peers. The default value is 10 seconds.

2. min-connections: This represents the minimum number of connections a node aims to maintain with its peers. If the number of active connections falls below this threshold and the min-connections number is too low, your node risks becoming unsynced. As the number of active peers approaches the min-connections value, the system will enter maintenance mode and log "too few connections," triggering attempts to connect to more peers. If you frequently observe "too few connections" warnings, consider lowering both this value and the expected-connections value.

3. expected-connections: This is the number of connections that the node expects to have under normal operation. If the number of connections is below this value, the node will attempt to create new connections. If you're seeing "too few connections" warnings, you might want to lower this value. However, be aware that having too few connections can lead to your node becoming unsynced.

4. max-connections: This is the maximum number of connections that the node will maintain. If the number of connections exceeds this value, the node will start closing connections. If you're seeing "too many connections" warnings, you might want to increase this value. However, be aware that having too many connections can lead to increased resource usage.

5. max_known_points: This parameter sets the maximum number of potential peers (or "points") that the node will keep track of. Each point represents a potential peer that the node could connect to. If the node discovers more points than this maximum, it will forget about the least recently used points. This parameter is related to network discovery and can be adjusted if you're having trouble finding enough peers to connect to.

6. max_known_peer_ids: This parameter sets the maximum number of peer IDs that the node will remember. Each peer ID represents a unique peer that the node has interacted with. If the node interacts with more peers than this maximum, it will forget about the least recently used peer IDs. This parameter is related to maintaining a history of peers and can be adjusted if you're frequently reconnecting to the same peers. In summary, max_known_points is about managing potential connections, while max_known_peer_ids is about remembering past interactions. Both can impact the node's ability to establish and maintain connections with peers.


The min-connections setting is directly related to the "too few connections" warning. If the number of active connections drops below this value, the node will attempt to connect to more peers.

The expected-connections setting, on the other hand, is more of a target for the node. It's the number of connections that the node expects to have under normal operation. If the number of connections is below this value, the node will attempt to create new connections, but it won't log a "too few connections" warning unless the number of connections drops below min-connections.

So, if you're seeing "too few connections" warnings, adjusting min-connections is indeed likely to have a more direct impact. However, expected-connections could still be relevant, as it controls the node's proactive behavior in establishing new connections.

---
### About the log message "too few connections":

The log message "too few connections" is triggered when the number of active connections falls below the min_threshold defined in the P2P layer's maintenance worker configuration. This is part of the normal operation of the P2P network maintenance system and does not directly indicate that the node is in an unsynced state.

However, if the node consistently has too few connections, it might not have a diverse enough view of the network, which could potentially impact its ability to stay accurately synced with the blockchain.

---
### About synchronisation_threshold:

The synchronisation_threshold parameter is part of the synchronization heuristic used by the node to determine whether it is synchronized with the rest of the network.

The synchronization heuristic maintains a set of "candidates", where each candidate is a block that has been validated by a peer. The heuristic always keeps the most recent candidate from each peer.

The synchronisation_threshold parameter controls the number of these candidates that the heuristic considers when determining the synchronization status of the node.

Here's how it works:

- If synchronisation_threshold is negative, the node is always considered not synchronized.
- If synchronisation_threshold is 0, the node is always considered synchronized and the chain is not stuck.
- If synchronisation_threshold is greater than 0, the node's synchronization status depends on the timestamps of the most recent candidates:
- The node is considered synchronized and not stuck if there are at least synchronisation_threshold candidates that are more recent than the latency parameter.
- The node is considered synchronized but stuck if the synchronisation_threshold most recent candidates all have the same timestamp.
- The node is considered not synchronized in all other cases.

There is a default value for the synchronisation-threshold parameter. If you do not set it, the default value is 4. This is mentioned in the sync.rst in tezos/tezos.
Other values are acceptable for ``threshold``, but a small
``threshold`` (between ``2`` and ``10``; the default being ``4``) is
probably best: performances and accuracy may degrade for values much
higher than ``10``.

--> We probably want to set a decenlty high value for a Mainnet node. Whereas a low value (0 or 1 or 2) may be necessary for testnets (also depending on the testnet).

---
### Synchronization Heuristic:
todo