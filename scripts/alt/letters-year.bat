@echo off
set saxon_jar="..\SaxonHE10-3J\saxon-he-10.3.jar"
set work_dir=%~dp0
pushd %work_dir%
java -jar %saxon_jar% -xsl:"%work_dir%letters-year.xsl" -s:"%work_dir%letters-year.xsl" INPUT_DIR="%work_dir%..\data-preprocessed\letters-xml"	
popd
