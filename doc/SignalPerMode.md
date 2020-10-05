

| Signal  |  Windows   |   Linux    |       Mac        |
| ------- | ---------- | ---------- | ---------------- |
| SIGINT  | spawn,fork | spawn,fork | shell,spawn,fork |
| SIGKILL | spawn,fork | spawn,fork | shell,spawn,fork |


|        Routine         |  Windows   |   Linux    |       Mac        |
| ---------------------- | ---------- | ---------- | ---------------- |
| endStructuralSigint    | spawn,fork | spawn,fork | shell,spawn,fork |
| endStructuralSigkill   | spawn,fork | spawn,fork | shell,spawn,fork |
| endStructuralTerminate |            | spawn,fork | shell,spawn,fork |
| endStructuralKill      | spawn,fork | spawn,fork | shell,spawn,fork |


