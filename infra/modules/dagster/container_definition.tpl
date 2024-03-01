[
  {
    "name": "${name}",
    "image": "${image}",
    "essential": true,
    "command": ${command},
    "environment": ${environment},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${awslogs_group}",
        "awslogs-region": "${awslogs_region}",
        "awslogs-stream-prefix": "${awslogs_stream_prefix}"
      }
    },
    "portMappings": [
      {
        "name": "${port_mapping_name}",
        "containerPort": ${container_port},
        "hostPort": ${host_port}
      }
    ]
  }
]
