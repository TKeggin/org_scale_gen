url     <- "https://cran.r-project.org/src/contrib/Archive/PhyloMeasures/PhyloMeasures_2.1.tar.gz"
pkgFile <- "PhyloMeasures_2.1.tar.gz"
download.file(url = url, destfile = pkgFile)

# Expand the zip file using whatever system functions are preferred

# look at the DESCRIPTION file in the expanded package directory

# Install dependencies list in the DESCRIPTION file

# Install package
install.packages(pkgs=pkgFile, type="source")

# Delete package tarball
unlink(pkgFile)