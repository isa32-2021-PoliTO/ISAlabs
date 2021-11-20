//
// Created by repex on 13/11/2021.
//

#include <iostream>
#include <cmath>
#include <fstream>
#include <filesystem>
#include "DaddaTree.h"

std::vector<std::vector<std::shared_ptr<Signal>>> DaddaTree::initColumns(short Nbits) {
    std::vector<std::vector<std::shared_ptr<Signal>>> colVector; // New column vector

    for (short int i=0; i <= Nbits; i++) {
        std::vector<std::shared_ptr<Signal>> col;
        auto it = col.begin();
        for (short int j=0; j<=i/2; j++) {
            it = col.insert(it, std::make_shared<Signal>(Signal::s_type::P, j, i - 2 * j ));
        }

        if(i%2 == 0 && i!=Nbits) {
            it = col.insert(it, std::make_shared<Signal>(Signal::s_type::S, i / 2, NA ));
        }

        colVector.emplace(colVector.end(), col);
    } // 'i' stays for column number

    for (short int i = Nbits+1; i < 2*Nbits; i++) {
        std::vector<std::shared_ptr<Signal>> col;
        auto it = col.begin();
        if(i == (Nbits+3)){
            col.push_back(std::make_shared<Signal>(Signal::s_type::nS, 0, NA));
            it=col.end();
        }
        if( i < (Nbits+3) ) {
            it = col.insert(it, std::make_shared<Signal>(Signal::s_type::S, 0, NA));
        }
        else {
            if ( (i-Nbits-1)%2 == 0 ) {
                it = col.insert(it, std::make_shared<Signal>(Signal::s_type::nS, (i - Nbits - 1) / 2, NA));
            }
            else {
                it = col.insert(it, std::make_shared<Signal>(Signal::s_type::One, NA, NA));
            }
        }
        it++;

        for (short int j = (i - Nbits + 1)/2; j <= Nbits/2; j++) {
            it = col.insert(it, std::make_shared<Signal>(Signal::s_type::P, j, i - 2*j));
            it++;
        }

        colVector.emplace(colVector.end(), col);
    }

    return colVector;
}

unsigned int DaddaTree::getTreeSize() {
    unsigned int size=0;

    for ( auto & in : ppTree ){
        if ( size < in.size() )
            size = in.size();
    }

    return size;
}

void DaddaTree::assignAdders(short int Nbits) {
    constexpr double k = 1.5;   // l(i+1) = floor( 3 * l(i)/2 ) = floor( k * l(1) )
    int l=2;  // l(0) = 2
    ppTree = initColumns(Nbits);    // Init Dadda point map
    unsigned int size = getTreeSize();  // Max size of the tree

    while ( k * l < size ){
        l = floor(k*l);
    }

    while ( size > 2 ) {
        daddaReduction(l);   // Updates the entire tree
        size = getTreeSize();   // Updates tree size
        l =  ceil( l / k );
    }

    // Last part => l=2
    for (auto it=this->ppTree.begin(); it != this->ppTree.end(); it++ ) {
        if( it->size() == 2 ) {
            insertHA(it);
        }
        else if( it->size() == 3 ){
            insertFA(it);
        }
    }
}

void DaddaTree::daddaReduction(unsigned int l) {
    for (short int i=0; i<ppTree.size(); i++) {
        int whatchdog = 0;
        auto it = ppTree.begin()+i;
        while ( it->size() > l ) {
            if ( it->size() > l+1 )
                insertFA(it);
            else
                insertHA(it);
            whatchdog++;
            if (whatchdog > 1000000)
                throw std::runtime_error("DaddaTree::daddaReduction: infinite loop detected. column.size()=" +
                std::to_string(it->size()) + ". minReduction = " + std::to_string(l));
        }
    }
}

void DaddaTree::insertHA(std::vector<std::vector<std::shared_ptr<Signal>>>::iterator it) {
    auto Sum = std::make_shared<Signal>(Signal::s_type::Sum, Nadders, NA);
    auto Cout = std::make_shared<Signal>(Signal::s_type::Cout, Nadders, NA);
    if (it == ppTree.end() )
        throw std::runtime_error("Added HA to an invalid column number.");
    //Assign signals to an halfadder
    auto HA = std::make_shared<HalfAdder>(it->at(0), it->at(1), Sum, Cout);
    Nadders++;

    //Remove two columns elements
    it->erase(it->begin());
    it->erase(it->begin());
    //Insert Sum at the top of the column
    it->push_back(Sum);

    //Insert Cout at the top of the next column
    it += 1;
    if(it == ppTree.end() ) {
        it = ppTree.emplace(it, std::vector<std::shared_ptr<Signal>>());
        it->push_back(Cout);
    }
    else {
        it->push_back(Cout);
    }

    //Adding the halfadder to the adders list
    addersVector.push_back(HA);
}

void DaddaTree::insertFA(std::vector<std::vector<std::shared_ptr<Signal>>>::iterator it) {
    auto Sum = std::make_shared<Signal>(Signal::s_type::Sum, Nadders, NA);
    auto Cout = std::make_shared<Signal>(Signal::s_type::Cout, Nadders, NA);
    if (it == this->ppTree.end() )
        throw std::runtime_error("Added HA to an invalid column number.");
    //Assign signals to an fulladder
    auto FA = std::make_shared<FullAdder>(it->at(0), it->at(1), it->at(2), Sum, Cout);
    Nadders++;

    //Remove three columns elements
    it->erase(it->begin());
    it->erase(it->begin());
    it->erase(it->begin());
    //Insert Sum at the top of the column
    it->push_back(Sum);

    //Insert Cout at the top of the next column
    it += 1;
    if(it == this->ppTree.end() ) {
        it = this->ppTree.emplace(it, std::vector<std::shared_ptr<Signal>>());
        it->push_back(Cout);
    }
    else {
        it->push_back(Cout);
    }

    //Adding the halfadder to the adders list
    addersVector.push_back(FA);
}

void DaddaTree::generateVHDL(short Nbits) {
    std::ofstream file;
    const std::string TEname = "Mult_Dadda" + std::to_string(Nbits);
    const std::string HAname = "half_adder";
    const std::string FAname = "full_adder";
    const std::string MBEname = "mbe_ppst";
    enum MBEIO { three_digit, a, pp, S };
    const std::string MBEIOnames[] = {
            "triplet",  //Name of three_digit input
            "Y",        //Name of a input
            "pp",       //Name of pp output
            "S"
    };
    const std::filesystem::path dir_path="./vhdl/";

    if( !(std::filesystem::is_directory(dir_path)) )
        std::filesystem::create_directories(dir_path);

    file.open(dir_path.string() + TEname + ".vhd");

    file << "library IEEE;";
    file << "\nuse IEEE.std_logic_1164.all;";

    file << "\n\nentity "+ TEname + " is";
    file << "\n\tgeneric( N : natural := " + std::to_string(Nbits) + ");";

    file << "\n\tport( x : in std_logic_vector(N - 1 downto 0);";
    file << "\n\t\ty : in std_logic_vector(N - 1 downto 0);";
    file << "\n\t\tz : out std_logic_vector(2*N - 1 downto 0));";

    file << "\nend entity "+ TEname + ";";

    file << "\n\narchitecture arch of "+ TEname + " is";

    file << "\ncomponent "+FAname+" is\n\tport(\n\t\ta : in std_logic;\n\t\tb : in std_logic;\n\t\tcin : in  std_logic;\n\t\ts : out std_logic;\n\t\tcout : out std_logic);\nend component;\n";

    file << "\ncomponent "+HAname+" is\n\tport(\n\t\ta : in std_logic;\n\t\tb : in std_logic;\n\t\ts : out std_logic;\n\t\tcout : out std_logic);\nend component;\n";

    file << "\ncomponent "+MBEname+" is\n\tgeneric(n : natural := 32);\n\tport("+MBEIOnames[MBEIO::three_digit]+" : in std_logic_vector(2 downto 0);--sign bit representation\n\t\t"+MBEIOnames[MBEIO::a]+" : in std_logic_vector(N-1 downto 0);\n\t\t"+MBEIOnames[MBEIO::pp]+" : out std_logic_vector(N downto 0);\n\t\t"+MBEIOnames[MBEIO::S]+" : out std_logic);\nend component;";

    file << "\n\ntype "+SigName[Signal::s_type::P]+"_t is array (N/2 downto 0) of std_logic_vector(N downto 0);";
    file << "\nsignal "+SigName[Signal::s_type::P]+" : "+SigName[Signal::s_type::P]+"_t;";
    file << "\nsignal "+SigName[Signal::s_type::S]+", "+SigName[Signal::s_type::nS]+" : std_logic_vector(N/2 downto 0);";
    file << "\nsubtype "+SigName[Signal::s_type::Sum]+"_t is std_logic_vector(" + std::to_string(Nadders - 1) + " downto 0);";
    file << "\nsignal "+SigName[Signal::s_type::Sum]+" : "+SigName[Signal::s_type::Sum]+"_t;";
    file << "\nsubtype "+SigName[Signal::s_type::Cout]+"_t is std_logic_vector(" + std::to_string(Nadders - 1) + " downto 0);";
    file << "\nsignal "+SigName[Signal::s_type::Cout]+" : "+SigName[Signal::s_type::Cout]+"_t;";
    file << "\nsignal ppg0_three_digits, ppglast_three_digits : std_logic_vector(2 downto 0);";
    file << "\n\nbegin";
    file << "\n\nppg0_three_digits <= x(1 downto 0)&'0';";
    file << "\nppg0: "+MBEname+" generic map(N) port map(ppg0_three_digits, y, "+SigName[Signal::s_type::P]+"(0), "+SigName[Signal::s_type::S]+"(0));";
    file << "\n\nF0: for i in 1 to n/2-1 generate";
    file << "\n\tppgi: "+MBEname+" generic map(N) port map(x((2*i + 1) downto (2*i - 1)), y, "+SigName[Signal::s_type::P]+"(i), "+SigName[Signal::s_type::S]+"(i));\nend generate;";
    file << "\n\nppglast_three_digits(N - 2*(N/2) downto 0) <= x(n - 1 downto 2*(n/2) -1);";
    file << "ppglast_three_digits(2 downto N - 2*(N/2) + 1) <= (others => '0');";
    file << "\nppglast: "+MBEname+" generic map(N) port map(ppglast_three_digits, y, "+SigName[Signal::s_type::P]+"(n/2), "+SigName[Signal::s_type::S]+"(n/2));\n";

    int HAcnt = 1;
    int FAcnt = 1;
    for(auto& adder: addersVector) {
        if (dynamic_cast<HalfAdder*>(adder.get())){
            file << "\nHA" + std::to_string(HAcnt) + " : "+HAname+" port map" + adder->toString() + ";";
            HAcnt++;
        }
        else if (dynamic_cast<FullAdder*>(adder.get())){
            file << "\nFA" + std::to_string(FAcnt) + " : "+FAname+" port map" + adder->toString() + ";";
            FAcnt++;
        }
    }

    file << "\n\nF1: for i in 0 to "+SigName[Signal::s_type::S]+"'length-1 generate\n\t"+SigName[Signal::s_type::nS]+"(i) <= not "+SigName[Signal::s_type::S]+"(i);\nend generate;\n";
    for(size_t i = 0; i < ppTree.size()-2; i++){
        auto it = ppTree.begin()+i;
        if(it != ppTree.end()){
            file << "\nz(" << i << ") <= " << it->at(0)->toString() << ";";
        }
    }

    file << "\n\nend architecture;";

    file.close();

    for(size_t i = 0; i < ppTree.size(); i++) {
        auto it = ppTree.begin() + i;
        if(it != ppTree.end()) {
            std::cout << "col: " << i << " size:" << it->size() << std::endl;
        }
    }

    //generate testbench

    file.open(dir_path.string() + "tb" + std::to_string(Nbits) + ".vhd", std::ofstream::out);
    file << "LIBRARY ieee;\n"
         << "USE ieee.std_logic_1164.all;\n"
         << "USE ieee.numeric_std.all;\n"
         << "\n"
         << "ENTITY tb" << std::to_string(Nbits) << " IS\n"
         << "END tb" << std::to_string(Nbits) << ";\n"
         << "ARCHITECTURE arc OF tb" << std::to_string(Nbits) << " IS\n"
         << ""
         << "constant N : natural := " << std::to_string(Nbits) << ";\n"
         << "SIGNAL x : STD_LOGIC_VECTOR(N-1 DOWNTO 0);\n"
         << "SIGNAL y : STD_LOGIC_VECTOR(N-1 DOWNTO 0);\n"
         << "SIGNAL z : STD_LOGIC_VECTOR(2*N-1 DOWNTO 0);\n"
         << "signal prod : STD_LOGIC_VECTOR(2*N-1 DOWNTO 0);\n"
         << "COMPONENT "+ TEname << "\n"
         << "	PORT (\n"
         << "	x : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);\n"
         << "	y : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);\n"
         << "	z : OUT STD_LOGIC_VECTOR(2*N-1 DOWNTO 0)\n"
         << "	);\n"
         << "END COMPONENT;\n"
         << "BEGIN\n"
         << "	i1 : Mult_Dadda" << std::to_string(Nbits) << "\n"
         << "	PORT MAP (\n"
         << "	x => x,\n"
         << "	y => y,\n"
         << "	z => z\n"
         << "	);\n"
         << "\n"
         << "        prod <= std_logic_vector(unsigned(x)*unsigned(y));\n"
         << "        \n"
         << "PROCESS\n"
         << "BEGIN\n"
         << "  x <= (0 => '1', others => '0');\n"
         << "  for i in 0 to N-1 loop\n"
         << "    y <= (others => '0');\n"
         << "    y(i) <= '1';\n"
         << "    wait for 10 ns;\n"
         << "  end loop;\n"
         << "  wait for 10 ns;\n"
         << "\n"
         << "  y <= (0 => '1', others => '0');\n"
         << "  for i in 0 to N-1 loop\n"
         << "    x <= (others => '0');\n"
         << "    x(i) <= '1';\n"
         << "    wait for 10 ns;\n"
         << "  end loop;\n"
         << "\n"
         << "  x <= (0 => '1', 1 => '1', others => '0');\n"
         << "  wait for 10 ns;\n"
         // << "  x <= (0 => '1', 1 => '0', 2 => '1', others => '0');\n"
         // << "  wait for 10 ns;\n"
         << "  \n"
         << "  wait;\n"
         << "end process;\n"
         << "\n"
         << "END arc;\n";

    file.close();
}


