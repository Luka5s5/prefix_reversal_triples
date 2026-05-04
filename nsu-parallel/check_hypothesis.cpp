#include "main.cpp"
#include <fstream>
#include <sstream>

int main(int argc, char *argv[]) {
    std::ifstream fin("nohup.out");
    std::string line;
    std::vector<std::vector<int>> generating, non_generating;
    while (std::getline(fin, line)) {
        std::istringstream lstream(line);
        char ch;
        int a,b,n;
        bool generates = false;
        std::string ending;
        lstream >> ch >> a >> ch >> b >> ch >> n >> ch >> ch >> ending;
        generates = (ending.size() == 1);
        std::cout << a << ' ' << b << ' ' << n << ' ' << generates << std::endl;
        if (generates){
            generating.push_back({a, b, n});
        }
        else{
            non_generating.push_back({a, b, n});
        }
    }

	//
	//    }
	//    // Parse integer parameters
	//    try {
	//        int delta = std::stoi(argv[2]);
	//        int k = std::stoi(argv[3]);
	// std::cout<<"r_"<<k<<" r_n-"<<-delta<<" r_n"<<std::endl;
	//        int nmin = std::stoi(argv[4]);
	//        int nmax = std::stoi(argv[5]);
	//        int nstep = std::stoi(argv[6]);
	// std::cout<<"for n from "<<nmin<<" to "<<nmax<<" with step "<<nstep<<std::endl;
	//        find_recipes_general_parallel(delta, k, checker, nmin, nmax, nstep);
	//    } catch (const std::exception& e) {
	//        std::cerr << "Error converting arguments to integers: " << e.what() << '\n';
	//        return 1;
	//    }
	//
	//    return 0;
}
