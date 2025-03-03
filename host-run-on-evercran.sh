# TODO: make args capture whole args...
# TODO: R 0.49 segfaults
# TODO: 
#       - no .Last.sys in 3.0.0 or 2.15.3
#       - no last.warning in 4.2.0/1... 
#       

source host-functions.sh

# cleanup
rm docker-data/*

# run_image pre
run_image 0.x
run_image 1.x
run_image 2.x
 
run_image 3.0.0
run_image 3.0.1
run_image 3.0.2
run_image 3.0.3
run_image 3.1.0
run_image 3.1.1
run_image 3.1.2
run_image 3.1.3
run_image 3.2.0
run_image 3.2.1
run_image 3.2.2
run_image 3.2.3
run_image 3.2.4
run_image 3.2.5
run_image 3.3.0
run_image 3.3.1
run_image 3.3.2
run_image 3.3.3
run_image 3.4.0
run_image 3.4.1
run_image 3.4.2
run_image 3.4.3
run_image 3.4.4
run_image 3.5.0
run_image 3.5.1
run_image 3.5.2
run_image 3.5.3
run_image 3.6.0
run_image 3.6.1
run_image 3.6.2
run_image 3.6.3
run_image 4.0.0
run_image 4.0.1
run_image 4.0.2
run_image 4.0.3
run_image 4.0.4
run_image 4.0.5
run_image 4.1.0
run_image 4.1.1
run_image 4.1.2
run_image 4.1.3
run_image 4.2.0
run_image 4.2.1
run_image 4.2.2
run_image 4.2.3
run_image 4.3.0
run_image 4.3.1
run_image 4.3.2
run_image 4.3.3
run_image 4.4.0
run_image 4.4.1
run_image 4.4.2
run_image 4.4.3
