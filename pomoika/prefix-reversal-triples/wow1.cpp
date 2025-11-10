#include "main.cpp"


int main(){
    std::cout<<"This program tries to find r_k-2 or r_2 using r_k-1, r_k, r_n"<<std::endl;
    int n = 11;
    int k = 6;
    std::cout<<"Input n: ";
    std::cin>>n;
    std::cout<<"Input k: ";
    std::cin>>k;
    std::cout<<"Computation for r_"<<k-1<<" r_"<<k<<" r_"<<n<<std::endl;
    find_good_trans(n,k);
}
