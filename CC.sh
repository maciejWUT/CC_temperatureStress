#!/bin/bash

#ssh ip:
ip="40.86.73.70"
echo IP: $ip

cd task/plateHolePar
source /usr/lib/openfoam/openfoam2112/etc/bashrc
decomposePar
cd ../..

scp -i ~/Downloads/OpenFoamCC_key.pem -r task azureuser@$ip:/home/azureuser/OpenFoam


ssh -i ~/Downloads/OpenFoamCC_key.pem azureuser@$ip <<"ENDSSH"
cd ~/OpenFoam/task/plateHole
source /usr/lib/openfoam/openfoam2112/etc/bashrc
time solidDisplacementFoam >> log &
cd ~/OpenFoam/task/plateHolePar;
time mpirun --hostfile ~/hostfile -np 4 solidDisplacementFoam -parallel >> log &

ENDSSH


scp -i ~/Downloads/OpenFoamCC_key.pem -r azureuser@40.86.73.70:/home/azureuser/OpenFoam/task CC

source /usr/lib/openfoam/openfoam2112/etc/bashrc
cd task/plateHole
postProcess -func 'components(sigma)' -time '20:10000'	
cd ../plateHolePar
reconstructPar
postProcess -func 'components(sigma)' -time '20:10000'
cd ..
