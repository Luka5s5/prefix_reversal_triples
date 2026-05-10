#include "main.cpp"
#include <fstream>
#include <sstream>
#include <map>
#include <tuple>

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
        lstream >> ch >> a >> ch >> b >> ch >> n >> ch  >> ending;
        generates = (ending.size() == 2) && (ending[0]=='1');
        // std::cout << a << ' ' << b << ' ' << n << ' ' << generates << std::endl;
        if (generates){
            generating.push_back({a, b, n});
        }
        else{
            non_generating.push_back({a, b, n});
        }
    }
    std::vector<std::string> known_recipes;
    std::map<std::tuple<int,int,int>, std::string> recipes_cycles;
    std::map<std::tuple<int,int,int>, std::string> recipes_adj;
    for (auto triple:generating){
	std::cout<< "Finding cycle recipes for " << triple[0] << " " << triple[1] << " " << triple[2] << std::endl;
	std::vector<Permutation> base = {Prefix_by_delta(triple[2],triple[0]),Prefix_by_delta(triple[2],triple[1]),Prefix_by_delta(triple[2],0)};
	base.push_back(bake(base,"012"));
	
	std::string cycle_prev_rec = recipes_cycles.count(std::make_tuple(triple[0]-4, triple[1]-4, triple[2]-4))?recipes_cycles[std::make_tuple(triple[0]-4, triple[1]-4, triple[2]-4)]:"";
	std::string cycle_recipe = check_recipes(base, is_n_cycle, known_recipes);
	if(cycle_recipe == "") cycle_recipe = find_recipes_general_parallel(triple[1], triple[0], is_n_cycle, triple[2], triple[2], 1, cycle_prev_rec);
	recipes_cycles[std::make_tuple(triple[0], triple[1], triple[2])] = cycle_recipe;
	
	known_recipes.push_back(cycle_recipe);
	auto n_cycle = bake(base, cycle_recipe);
	std::cout << "The cycle found: " << n_cycle.to_cycles() << std::endl;
	auto adj_checker = createAdjacentChecker(n_cycle);

	std::string adj_prev_rec = recipes_adj.count(std::make_tuple(triple[0]-4, triple[1]-4, triple[2]-4))?recipes_adj[std::make_tuple(triple[0]-4, triple[1]-4, triple[2]-4)]:"";
	std::string adj_recipe = check_recipes(base,adj_checker,known_recipes);
	if(adj_recipe == "") adj_recipe = find_recipes_general_parallel(triple[1], triple[0], adj_checker, triple[2], triple[2], 1, adj_prev_rec);
	recipes_cycles[std::make_tuple(triple[0], triple[1], triple[2])] = adj_recipe;

	known_recipes.push_back(adj_recipe);
	std::cout << "The adj found: " << bake(base, adj_recipe).to_cycles() << std::endl;
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
