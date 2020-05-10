# Short Description
This repository contains salt stack configuration scripts for IBM AppConnect Enterprise

## ACE11 Installation

The installation is implemented in the ace11.iib_user and ace11.ace_install states. For installation you just call the following states on your master:
1. salt '*' state.apply ace11.iib_user - creates the ACE11 shared installation user/group
2. salt '*' state.apply ace11.ace_install - installes ACE11 on your minion

All configurations are made in the states - user/group name, installation source path etc.

## ACE11 Configuration

The state ace11.ace_config enables you to configure your ACE11 environment using YAML definitions. The definions are stored in the pillars, see pillar/ace.sls. You describe your ACE11 environment in YAML and update your pillar cache on the minion:

salt '*' saltutil.refresh_pillar

You can then apply the environment configuration on your minion:

salt '*' state.apply ace11.ace_config

and get immediately the execution results.
