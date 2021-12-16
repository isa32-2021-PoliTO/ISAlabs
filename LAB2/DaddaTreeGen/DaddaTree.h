#ifndef DADDATREEGEN_DADDATREE_H
#define DADDATREEGEN_DADDATREE_H

#include "Logics.h"
#include <vector>
#include <memory>

class DaddaTree {
private:
    std::vector<std::shared_ptr<Adder>> addersVector;
    static constexpr int NA = 0;
    int Nadders = 0;
    std::vector<std::vector<std::shared_ptr<Signal>>> ppTree;
public:
    static std::vector<std::vector<std::shared_ptr<Signal>>> initColumns(short int Nbits);  //Generate an initialized column tree
    unsigned int getTreeSize();
    void daddaReduction(unsigned int l);
    void assignAdders(short int Nbits);
    void generateVHDL(short int Nbits);
    void insertHA(std::vector<std::vector<std::shared_ptr<Signal>>>::iterator it); // Insert a HA in the specific column pointed by it
    void insertFA(std::vector<std::vector<std::shared_ptr<Signal>>>::iterator it); // Insert a FA in the specific column pointed by it
};


#endif //DADDATREEGEN_DADDATREE_H
