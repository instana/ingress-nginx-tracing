#!/usr/bin/env ruby

require 'yaml'

deployment_document = YAML.load_stream(ARGF.read).find { |document| document['kind'] == 'Deployment' && document['metadata']['labels'] && document['metadata']['labels']['app.kubernetes.io/component'] == 'controller' } 
controller_container_spec = deployment_document['spec']['template']['spec']['containers'].find { |container| container['name'] == 'controller' }

puts controller_container_spec['image']