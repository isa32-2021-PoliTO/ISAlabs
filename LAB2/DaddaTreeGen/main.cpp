#include <iostream>
#include "DaddaTree.h"

int main( int argc, char *argv[] ) {
    short int Nbits=32;

    if (argc == 2){
        Nbits=(short int)std::stoi(argv[1]);
    }
    else {
        std::cout<<"Setting default number of bits to "<<Nbits<<std::endl;
    }

    DaddaTree tree;
    tree.assignAdders(Nbits);
    tree.generateVHDL(Nbits);
    return 0;
}
