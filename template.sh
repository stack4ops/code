#!/bin/sh

echo "Project Name: ${create_project_name:?}"

sed -i "s/{PROJECT_NAME}/${create_project_name}/g" README.md
