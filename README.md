# Panorama

1. The path to the image datasets has to be specified in the panaroma.m and panorama_imwarp.m scripts before running.
2. panaroma.m computes the image overlay with direct application of homography without imwarp.
3. panorama_imwarp.m uses imwarp
4. canvas_size.m and image_multiply.m functions are called by both above scripts for computing panorama size and overlay respectively.
5. do_ransac.m function is called by both scripts to implement RANSAC.
6. sift_demo.m is a script showing feature matching. Please specify path to image before running.
