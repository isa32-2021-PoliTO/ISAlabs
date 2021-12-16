#ifndef DADDATREEGEN_LOGICS_H
#define DADDATREEGEN_LOGICS_H

#include <string>
#include <memory>

const std::string SigName[6] = {
        "P",    //Name of signal P
        "Sum",  //Name of signal Sum
        "Cout", //Name of signal C_out
        "Cin",  //Name of signal C_in
        "Sig",    //Name of signal S
        "nSig"    //Name of signal nS
};  //Modify this if you want to change signal name in VHDL

class Signal {
public:
    enum s_type {P, Sum, Cout, Cin, S, nS, One, Zero};
private:
    s_type type;
    int x_i;
    int y_i;
public:
    Signal(s_type type, int x_i, int y_i);
    ~Signal();

    std::string toString();
};

class Adder {
protected:
    //List of pointers to signals which are related to this adders, they are protected otherwise they can't be passed to child classes
    std::shared_ptr<Signal> A;
    std::shared_ptr<Signal> B;
    std::shared_ptr<Signal> Sum;
    std::shared_ptr<Signal> C_out;
public:
    Adder(std::shared_ptr<Signal> A,
          std::shared_ptr<Signal> B,
          std::shared_ptr<Signal> S,
          std::shared_ptr<Signal> C_out
    );

    virtual std::string toString() = 0;

};

class FullAdder : public Adder {
private:
    //Adding declaration of this characterizing third addend
    std::shared_ptr<Signal> C_in;
public:
    FullAdder (
        std::shared_ptr<Signal> A,
        std::shared_ptr<Signal> B,
        std::shared_ptr<Signal> C_in,
        std::shared_ptr<Signal> Sum,
        std::shared_ptr<Signal> C_out
    ); //Copy constructor of Adder plus C_in constructor and its relations with signals

    virtual std::string toString(); //Generates FullAdders parenthesis
};

class HalfAdder : public Adder {
public:
    HalfAdder (
            std::shared_ptr<Signal> A,
            std::shared_ptr<Signal> B,
            std::shared_ptr<Signal> Sum,
            std::shared_ptr<Signal> C_out
            ); //Copy constructor of Adder and its relations with signals

    virtual std::string toString(); //Generates HalfAdders parenthesis
};


#endif //DADDATREEGEN_LOGICS_H
