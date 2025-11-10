#include "main.cpp"


int main(){
    int n_min, n_max, n_mod, n_mods, k_mod, k_mods;
    std::cout<<"This program tries to find a transposition in cycle r_k * r_k-1, using r_k r_k-1 r_n"<<std::endl;
    std::cout<<"Input n_min, n_max, n_mod, number_of_mods: ";
    std::cin>>n_min>>n_max>>n_mod>>n_mods;
    std::vector<int> n_rem(n_mods);
    std::cout<<"Input the reminders: ";
    for(auto &i:n_rem) std::cin>>i;

    std::cout<<"Input k_mod, number_of_mods: ";
    std::cin>>k_mod>>k_mods;
    std::vector<int> k_rem(k_mods);
    std::cout<<"Input the reminders: ";
    for(auto &i:k_rem) std::cin>>i;

    find_good_recipes(n_min,n_max,n_mod,n_rem,k_mod,k_rem);
}
