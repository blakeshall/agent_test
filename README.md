# Red Canary Agent Tester

Simple ruby script that generates activity for testing telemetry agents.

## Requirements

Ruby
Linux or MacOS

## How to run

`ruby agent_test.rb`

From there it has a simple cli for generating activities.

## Breakdown of Activities

### Process Spawn

Spawns a process, gets information on that process (via `ps`), logs the information

*Note* As this is using Ruby's `Process.spawn` if it is given a path to a exectutable it will instead give
the information on the subshell process, not the process generated from the executable. This could potentially
be resolved by scoping the `ps` call to the command, but then runs into issues if there are multiple processes
running the same command. The subshell process seemed like a good enough proxy.

### File Manipulation

Given a filepath, it will:

- create the file and close it
- reopen the file, modify it, and close it
- delete the file

It's all using the same filepath because that just seems tidy.

### Network Test

Sends a UDP message to 127.0.0.1, port 4913.

## Logs

The script logs all activities to a local `log.csv`. All activities include an activity description, timestamp,
username, process name, process command line, and PID. There is also an Extra Info column that contains
activity specific information; filepath for file creation, modification, and deletion, and more network information
for the network activity.

```csv
Activity,Timestamp,Username,Process name,Process command line,PID,Extra Info
Process Spawn,14:24:27,blake,sh,[sh] <defunct>,276494,
Create file,14:24:17,blake,ruby,ruby agent_test.rb,276455,Filepath: test.txt
Modify file,14:24:17,blake,ruby,ruby agent_test.rb,276455,Filepath: test.txt
Delete file,14:24:17,blake,ruby,ruby agent_test.rb,276455,Filepath: test.txt
Network Connection,14:24:17,blake,ruby,ruby agent_test.rb,276455,Destination: 127.0.0.1:4913 | Source: 127.0.0.1:4913 | Protocol: UDP | Bytes sent: 17
```
