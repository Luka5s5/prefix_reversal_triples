#include "main.cpp"

int main(int argc, char *argv[]) {
    if (argc != 7) {
        std::cerr << "Usage: " << argv[0] << " <checker_type> <delta> <k> <nmin> <nmax> <nstep>\n";
        return 1;
    }

    // Parse checker type
    std::function<bool(Permutation)> checker;
    if (std::string(argv[1]) == "0") {
	    std::cout<<"looking for an n-cycle"<<std::endl;
	checker = is_n_cycle;
    } else if (std::string(argv[1]) == "1") {
	    std::cout<<"looking for (1 2)"<<std::endl;
        checker = is_12;
    } else {
        std::cout << "Invalid checker type. Use 0 for is_n_cycle or 1 for is_12.\n";
        return 1;
    }

    // Parse integer parameters
    try {
        int delta = std::stoi(argv[2]);
        int k = std::stoi(argv[3]);
	std::cout<<"r_"<<k<<" r_n-"<<-delta<<" r_n"<<std::endl;
        int nmin = std::stoi(argv[4]);
        int nmax = std::stoi(argv[5]);
        int nstep = std::stoi(argv[6]);
	std::cout<<"for n from "<<nmin<<" to "<<nmax<<" with step "<<nstep<<std::endl;
        find_recipes_general_parallel(delta, k, checker, nmin, nmax, nstep);
    } catch (const std::exception& e) {
        std::cerr << "Error converting arguments to integers: " << e.what() << '\n';
        return 1;
    }

    return 0;
}

