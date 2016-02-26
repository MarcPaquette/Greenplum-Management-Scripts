#!/bin/bash
omreport storage vdisk |grep Write
for i in 0 1 2 3; do omconfig storage vdisk controller=0 vdisk=$i action=changepolicy writepolicy=fwb; done
omreport storage vdisk |grep Write

