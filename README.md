#dockerro#
This project should provide integration of Katello and Docker project, focusing on building Docker images based on content from Katello. This project is currently under development.

##Dependencies##
* [Katello](https://github.com/Katello/katello)
* [Foreman](https://github.com/theforeman/foreman)
* [Foreman_docker](https://github.com/theforeman/foreman-docker)

##Infrastructure requirements##
* Docker compute resource
* Properly set up DNS, the Docker compute resource should be able to lookup ip address for the machine running Foreman+Katello
* Set up products, repositories, content views and lifecycle environments
* Have dockerhost-builder image present in your infrastructure
  * Directly on the docker compute resource
    1. Run ```docker pull adamruzicka/dockerhost-builder```
    2. Run ```docker tag adamruzicka/dockerhost-builder:latest dockerhost-builder:latest```
    3. Set ```Settings``` > ```Dockerro``` > ```builder-image``` to ```dockerhost-builder```
  * In a repository in Katello
    1. Create docker repository
    2. Select the defaults for sync url
    3. Set upstream name to ```adamruzicka/dockerhost-builder```
    4. Sync the repository
    5. Copy the repoistory pull url
    6. Paste the copied url to ```Settings``` > ```Dockerro``` > ```builder-image```

##Deploying docker images into existing environments##
1. Go into ```Containers``` > ```New image```
2. Fill in the form
3. Click ```save```
4. Wait for the build to finish
5. Check out the new image in the repository you selected, the tag will be ```content_view_name-environment_name```
6. Add the repository to a content view (if it is already in one, skip to next step)
7. Publish new version of the content view
8. Promote the image to desired environment
 
##Deploying docker images for new versions##
1. Go into ```Containers``` > ```Docker image build configs```
2. Click ```New docker image build config```
3. Fill in the form
4. Click ```save```
5. Go into ```Containers``` > ```Docker image build configs``` again
6. Click ```Bulk build```
7. Check the configs you want to build
8. Select compute resource
9. Click ```build```
10. Wait for the builds to finish
11. Check out newly built images in repositories assigned in build configs, those images will have content from ```Library``` environment present and will be tagged with ```latest```

TODO:
- [x] Build docker images with packages from Katello
- [x] Build docker images with base image from Katello
- [x] Keep information about from which image and using which build config an image was built
- [x] Provide the possiblity to do bulk builds
- [ ] Trigger the bulk build automatically when publishing new version
- [ ] Trigger automatic rebuilds on incremental updates
- [ ] Notify about possible updates for docker images
- [ ] Rebuild images on base image update
