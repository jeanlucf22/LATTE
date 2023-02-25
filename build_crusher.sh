export PROGRESS_DIR=/autofs/nccs-svm1_home1/jeanluc/GIT/qmd-progress/install
export BML_DIR=/autofs/nccs-svm1_home1/jeanluc/GIT/bml/install

rm -rf build
mkdir build
cd build
cmake -DBML_DIR=${BML_DIR} -DPROGRESS_DIR=${PROGRESS_DIR} -DPROGRESS=on ..
