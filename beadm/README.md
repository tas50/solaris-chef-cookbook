# beadm Cookbook

Beadm cookbook is for managing ZFS Boot Environments (BEs), cookbook intended to be used by system administrators for managing multiple Oracle Solaris instances on a single system.

## Requirements

- Chef 12.5 or higher
- Oracle Solaris 11 and above

## Attributes

Beadm cookbook attributes.

### beadm::default

Key        | Type   | Description           | Default
---------- | ------ | --------------------- | -------
name       | String | BE name               |
new_be     | String | Target BE name        |
mountpoint | String | filesystem mountpoint |
options    | Hash   | ZFS properties        | true

## Usage

### beadm::default

## Creating a newbe

beadm 'newbe' do action :create end

## renaming a BE

beadm 'testbe' do action :rename new_be "testing" end

## Setting ZFS options while creation of BE

beadm 'newbe2' do options ({ 'recordsize' => '128K', 'compression' => 'on' }) action :create end

## Mounting of BE

beadm 'newbe2' do mountpoint "/mnt" action :mount end

## Mounting of BE

beadm 'newbe2' do action :umount end

## Pattern based destroy of BE

beadm 'newbe*' do action :destroy_pattern end

## Contributing

Process for contributing.

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

- Author:: Pradhap Devarajan([pradhap.devarajan@oracle.com](mailto:pradhap.devarajan@oracle.com))

```text
Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
