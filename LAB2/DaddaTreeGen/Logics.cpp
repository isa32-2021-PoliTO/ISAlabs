//
// Created by repex on 12/11/2021.
//

#include "Logics.h"

//Signal member definitions ---------------------------------------------------
Signal::Signal(Signal::s_type type, int x_i, int y_i) : type(type), x_i(x_i), y_i(y_i) {
    if(type != P && type != Sum && type != Cout && type != Cin && type != S && type != nS && type != One && type != Zero)
        throw std::runtime_error("Tried to create signal with invalid signal type at ("+std::to_string(x_i)+','+std::to_string(y_i));
}

std::string Signal::toString() {

    switch(type) {
        case P:
            return std::string(SigName[s_type::P]) + "(" + std::to_string(x_i) + ")(" + std::to_string(y_i) + ")";
        case Sum:
            return std::string(SigName[s_type::Sum]) + "(" + std::to_string(x_i) + ")";
        case Cout:
            return std::string(SigName[s_type::Cout]) + "(" + std::to_string(x_i) + ")";
        case Cin:
            return std::string(SigName[s_type::Cin]) + "(" + std::to_string(x_i) + ")";
        case S:
            return std::string(SigName[s_type::S]) + "(" + std::to_string(x_i) + ")";
        case nS:
            return std::string(SigName[s_type::nS]) + "(" + std::to_string(x_i) + ")";
        case One:
            return std::string("\'1\'");
        case Zero:
            return std::string("\'0\'");
        default:
            throw std::runtime_error("Tried to call toString() on signal with invalid signal type ("+std::to_string(x_i)+','+std::to_string(y_i)+")");
    }
}

Signal::~Signal() = default;

//Adder constructor definition ---------------------------------------------------
Adder::Adder(std::shared_ptr <Signal> A, std::shared_ptr <Signal> B, std::shared_ptr <Signal> S,
             std::shared_ptr <Signal> C_out) : A(A), B(B), Sum(S), C_out(C_out) { }

//FullAdder member definitions ---------------------------------------------------
FullAdder::FullAdder(std::shared_ptr<Signal> A, std::shared_ptr<Signal> B, std::shared_ptr<Signal> C_in, std::shared_ptr<Signal> Sum,
                     std::shared_ptr<Signal> C_out) : Adder(A, B, Sum, C_out), C_in(C_in) { }

std::string FullAdder::toString() {
    return "(" + A->toString() + ", " + B->toString() + ", " + C_in->toString() + ", " + Sum->toString() + ", " + C_out->toString() + ")";
}

//HalfAdder member definitions ---------------------------------------------------
HalfAdder::HalfAdder(std::shared_ptr<Signal> A, std::shared_ptr<Signal> B, std::shared_ptr<Signal> Sum,
                     std::shared_ptr<Signal> C_out) : Adder(A, B, Sum, C_out) { }

std::string HalfAdder::toString() {
    return "(" + A->toString() + ", " + B->toString() + ", " + Sum->toString() + ", " + C_out->toString() + ")";
}
