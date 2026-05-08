sudo docker start ae_dreamer_door
sudo docker start ae_dreamer_rc

sudo docker exec -it ae_dreamer_door bash
sudo docker exec -it ae_dreamer_rc bash

sudo docker stop ae_dreamer_door
sudo docker stop ae_dreamer_rc

sudo docker start ae_path_cmp
sudo docker exec -it ae_path_cmp bash
sudo docker stop ae_path_cmp
