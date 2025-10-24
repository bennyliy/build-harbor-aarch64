GIT_BRANCH="v2.14.0"

# first step: clone harbor ARM code
git clone https://github.com/alanpeng/harbor-arm.git

# Replace dev-arm image tag
sed -i "s#dev-arm#${GIT_BRANCH}-aarch64#g" harbor-arm/Makefile

# execute build command：Download harbor source code
cd harbor-arm
git clone --branch ${GIT_BRANCH} https://github.com/goharbor/harbor.git src/github.com/goharbor/harbor

echo "1 - will build harbor version: $(cat src/github.com/goharbor/harbor/VERSION)"
cd src/github.com/goharbor/harbor
echo will make compile_core
make compile_core
echo will make compile_jobservice
make compile_jobservice
echo will mkake compile_registryctl
make compile_registryctl
cd ../../../..

cp -f ../harbor/Makefile src/github.com/goharbor/harbor/
cp -f ../harbor/make/photon/Makefile src/github.com/goharbor/harbor/make/photon/
cp -f ../harbor/make/photon/portal/Dockerfile src/github.com/goharbor/harbor/make/photon/portal/
cp -f ../harbor/make/photon/registry/builder src/github.com/goharbor/harbor/make/photon/registry/
cp -f ../harbor/make/photon/registry/redis.patch src/github.com/goharbor/harbor/make/photon/registry/
cp -f ../harbor/src/portal/src/app/shared/components/about-dialog/about-dialog.component.html src/github.com/goharbor/harbor/src/portal/src/app/shared/components/about-dialog/

# echo "1 - will build harbor version: $(cat src/github.com/goharbor/harbor/VERSION)"
# make compile

# compile redis
echo "2 - Compile redis for arm architecture:"
make compile_redis

# Prepare to build arm architecture image data:
echo "3 - Prepare to build arm architecture image data:"
make prepare_arm_data

# Replace build arm image parameters：
echo "4 - Replace build arm image parameters:"
make pre_update

# Compile harbor components:
echo "5 - Compile harbor components:"
make compile COMPILETAG=compile_golangimage

# Build harbor arm image:
echo "6- Build harbor arm image:"
make build GOBUILDTAGS="include_oss include_gcs" BUILDBIN=true TRIVYFLAG=true GEN_TLS=true PULL_BASE_FROM_DOCKERHUB=false
