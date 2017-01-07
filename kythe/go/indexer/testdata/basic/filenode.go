// Package file verifies that a file node is generated by the indexer, and that
// it has the correct relationship to its package.
//
//- File=vname("", "test", "", "src/test/basic/filenode.go", "").node/kind file
package file

//- Pkg=vname("package", "test", "", "basic", "go").node/kind package
//- File childof Pkg
