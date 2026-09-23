# TODO: make args capture whole args...
# TODO: R 0.49 segfaults
# TODO: 
#       - no .Last.sys in 3.0.0 or 2.15.3
#       - no last.warning in 4.2.0/1... 
#       

source host-functions.sh

# GitHub Actions passes --html-help; the usual local run remains data-only.
HTML_HELP=$1

# cleanup
rm docker-data/*

while read -r IMAGE; do
  run_image "$IMAGE" "$HTML_HELP"
done < evercran-images.txt
