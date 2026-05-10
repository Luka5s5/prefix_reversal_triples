#include <ostream>
#include <vector>
#include <iostream>
#include <stdexcept>
#include <algorithm>
#include <queue>
#include <unordered_set>
#include <functional>
#include <cstdlib>
#include <sstream>
#include <thread>
#include <mutex>
#include <atomic>
#include <cmath>
#include <string>
#include <utility>

class Permutation
{
private:
    std::vector<int> p;
    int n;

public:
    int size() const
    {
        return this->n;
    }

    std::vector<int> get_vect() const{
        return this->p;
    }

    Permutation(int n, std::vector<int> p = {}) : n(n)
    {
        if (p.empty())
        {
            this->p.resize(n);
            for (int i = 0; i < n; ++i)
            {
                this->p[i] = i + 1; 
            }
        }
        else
    {
            this->p = p;
        }
    }

    friend std::ostream &operator<<(std::ostream &os, const Permutation &perm)
    {
        os << "[";
        for (size_t i = 0; i < perm.p.size(); ++i)
        {
            os << perm.p[i];
            if (i < perm.p.size() - 1)
                os << ", ";
        }
        os << "]";
        return os;
    }

    int operator[](int index) const
    {
        if (index >= 0 && index < n)
        {
            return p[index];
        }
        else
    {
            throw std::out_of_range("Index out of range");
        }
    }

    Permutation operator*(const Permutation &other) const
    {
        if (this->n != other.n)
        {
            throw std::invalid_argument("Permutations of different sizes");
        }
        std::vector<int> new_p(this->n);
        for (int i = 0; i < this->n; ++i)
        {
            new_p[i] = this->p[other.p[i] - 1];
        }
        return Permutation(this->n, new_p);
    }


    Permutation pow(int a) const
    {
        if (a == 0)
        {
            return Permutation(n);
        }
        if (a == 1)
        {
            return *this;
        }
        if (a < 0)
        {
            throw std::invalid_argument("Negative exponent not supported");
        }
        Permutation result = this->pow(a / 2);
        result = result * result;
        if (a % 2 != 0)
        {
            result = result * (*this);
        }
        return result;
    }

    std::string to_cycles() const
    {
        std::string ans = "";
        std::vector<bool> used(n, false);
        for (int i = 0; i < n; ++i)
        {
            if (!used[i])
            {
                used[i] = true;
                ans += "(" + std::to_string(i + 1);
                int to = p[i] - 1;
                while (to != i)
                {
                    used[to] = true;
                    ans += " " + std::to_string(to + 1);
                    to = p[to] - 1;
                }
                ans += ") ";
            }
        }
        return ans;
    }

    std::vector<std::vector<int>> to_actual_cycles() const
    {
        std::vector<std::vector<int>> ans;
        std::vector<bool> used(n, false);
        for (int i = 0; i < n; ++i)
        {
            if (!used[i])
            {
                used[i] = true;
                ans.push_back({i+1});
                int to = p[i] - 1;
                while (to != i)
                {
                    used[to] = true;
                    ans.rbegin()->push_back(to+1);
                    to = p[to] - 1;
                }
            }
        }
        return ans;
    }

    std::vector<int> get_signature() const
    {
        std::vector<bool> used(n, false);
        std::vector<int> lengths;
        for (int i = 0; i < n; ++i)
        {
            if (!used[i])
            {
                int start = i, count = 0;
                do
                {
                    start = p[start] - 1;
                    used[start] = true;
                    count++;
                } while (start != i);
                lengths.push_back(count);
            }
        }
        std::sort(lengths.begin(), lengths.end());
        return lengths;
    }

    std::vector<Permutation> get_all_powers() const
    {
        std::vector<Permutation> powers;
        Permutation currentPerm = *this;
        for (int i = 1; true; ++i)
        {
            powers.push_back(currentPerm);
            currentPerm = currentPerm * (*this);
            if (std::equal(currentPerm.p.begin(), currentPerm.p.end(), this->p.begin()))
            {
                break;
            }
        }
        return powers;
    }

    size_t get_hash() const{
        std::size_t hashValue = 0;
        for (int num : this->get_vect()) {
            hashValue ^= std::hash<int>()(num) + 0x9e3779b9 + (hashValue << 6) + (hashValue >> 2);
        }
        return hashValue;
    }

        Permutation operator==(const Permutation &other) const {
        return (this->get_hash() == other.get_hash());
    }

};

namespace std {
template <>
struct hash<Permutation> {
    std::size_t operator()(const Permutation& perm) const {
        return perm.get_hash();
    }
};
}

Permutation Prefix(int n, int k)
{
    std::vector<int> a(n);
    for (int i = 0; i < n; i++)
    {
        a[i] = (i < k) ? k - i : i + 1;
    }
    return Permutation(n, a);
}

Permutation bake(std::vector<Permutation> generators, std::string recipe)
{
    auto ans = Permutation(generators[0].size());
    for (auto i : recipe)
    {
        ans = (ans * generators[i - '0']);
    }
    return ans;
}

bool is_12(Permutation p){
    auto perm_vec = p.get_vect();
    if (p.size()<2) return false;
    auto all_good = true;
    for (int i=2;i<p.size();i++){
        all_good&=(perm_vec[i]==i+1);
    }
    return perm_vec[0]==2 && perm_vec[1]==1 && all_good;
}

std::function<bool(Permutation)> createAdjacentChecker(Permutation c) {
    auto vec=c.to_actual_cycles()[0];
    return [vec](Permutation p) {
        std::vector<std::vector<int>> cycles = p.to_actual_cycles();
        std::sort(cycles.begin(),cycles.end(),[](std::vector<int> p1, std::vector<int> p2){return p1.size()<p2.size();});
        bool all_good=true;
        int cyc_2=0;
        std::vector<int> cyc2;
        for(int i=0;i<cycles.size();i++){
            if(cycles[i].size()==2){
                cyc_2++;
                cyc2=cycles[i];
                continue;
            }
            all_good&=(cycles[i].size()%2==1);
        }

        if (cyc_2!=1 || !all_good){
            return  false;
        }

        for(int i=0;i<=vec.size();i++){
            if((vec[i%vec.size()]==cyc2[0] && vec[(i+1)%vec.size()]==cyc2[1]) || (vec[i%vec.size()]==cyc2[1] && vec[(i+1)%vec.size()]==cyc2[0])){
                return true;
            }
        }

        for(int i=0;i<=vec.size();i++){
            if((vec[i%vec.size()]==cyc2[0] && vec[(i+vec.size()-1)%vec.size()]==cyc2[1]) || (vec[i%vec.size()]==cyc2[1] && vec[(i+vec.size()-1)%vec.size()]==cyc2[0])){
                return true;
            }
        }
        return false;
    };
}

std::string check_recipes(std::vector<Permutation> gens, std::function<bool(Permutation)> checker, std::vector<std::string> recipes) {
    for(auto recipe:recipes)
        if (checker(bake(gens,recipe)))
            return recipe;
    return "";
}

std::string parallel_bfs(std::vector<Permutation> gens, std::function<bool(Permutation)> checker, std::string start_recipe = "") {
    auto st = bake(gens, start_recipe);
    if (checker(st)) {
        return start_recipe;
    }

    std::unordered_set<size_t> seen;
    seen.insert(st.get_hash());

    std::vector<std::pair<Permutation, std::string>> current_frontier;
    current_frontier.push_back({st, start_recipe});

    std::atomic<bool> stop_flag(false);
    std::mutex seen_mutex;
    std::mutex next_frontier_mutex;
    std::mutex solution_mutex;
    bool solution_found = false;
    std::string solution_recipe = "";

    size_t num_threads = std::thread::hardware_concurrency();
    if (num_threads < 1) num_threads = 1;

    while (!current_frontier.empty() && !stop_flag) {
        std::vector<std::pair<Permutation, std::string>> next_frontier;

        size_t total_nodes = current_frontier.size();
        size_t chunk_size = (total_nodes + num_threads - 1) / num_threads;
        std::vector<std::thread> threads;

        for (size_t t = 0; t < num_threads; t++) {
            size_t start_idx = t * chunk_size;
            size_t end_idx = std::min(start_idx + chunk_size, total_nodes);
            if (start_idx >= end_idx) continue;

            threads.emplace_back([&](size_t s, size_t e) {
                for (size_t idx = s; idx < e && !stop_flag; idx++) {
                    const Permutation& v = current_frontier[idx].first;
                    const std::string& rec = current_frontier[idx].second;

                    for (size_t i = 0; i < gens.size() && !stop_flag; i++) {
                        Permutation to = v * gens[i];
                        size_t hash = to.get_hash();

                        if (checker(to)) {
                            std::lock_guard<std::mutex> lock(solution_mutex);
                            if (!solution_found) {
                                solution_found = true;
                                solution_recipe = rec + std::to_string(i);
                            }
                            stop_flag.store(true, std::memory_order_relaxed);
                            break;
                        }

                        bool unseen = false;
                        {
                            std::lock_guard<std::mutex> lock(seen_mutex);
                            if (seen.find(hash) == seen.end()) {
                                seen.insert(hash);
                                unseen = true;
                            }
                        }

                        if (unseen) {
                            std::lock_guard<std::mutex> lock(next_frontier_mutex);
                            next_frontier.push_back({to, rec + std::to_string(i)});
                        }
                    }
                }
            }, start_idx, end_idx);
        }

        for (auto& t : threads) {
            t.join();
        }

        if (stop_flag) break;

        current_frontier = std::move(next_frontier);
    }

    return solution_found ? solution_recipe : "-1";
}

std::string parallel_bfs(std::vector<Permutation> base, std::vector<std::string> gens_recipes, std::function<bool(Permutation)> checker, std::string start_recipe = "") {
    std::vector<Permutation> gens;
    for (int i = 0; i < gens_recipes.size(); i++) {
        gens.push_back(bake(base, gens_recipes[i]));
    }
    std::string bad_ans = parallel_bfs(gens, checker, start_recipe);
    std::string og_ans;
    for (int i = 0; i < bad_ans.size(); i++) {
        og_ans += gens_recipes[(bad_ans[i] - '0')];
    }
    return og_ans;
}

std::string bfs(std::vector<Permutation> gens,std::function<bool(Permutation)> checker,std::string start_recipe="")
{
    auto n=gens[0].size();
    auto st = bake(gens,start_recipe);
    std::unordered_set<size_t> seen;
    std::queue<std::pair<Permutation,std::string>> q;
    q.push({st,start_recipe});
    seen.insert(st.get_hash());
    if(checker(st)){
        return start_recipe;
    }
    while(!q.empty()){
        auto v = q.front().first;
        auto rec = q.front().second;
        q.pop();
        if(checker(v)){
            return rec;
        }
        for(int i=0;i<gens.size();i++){
            auto to = v*gens[i];
            if(seen.count(to.get_hash())>=1){
                continue;
            }
            seen.insert(to.get_hash());
            q.push({to,rec+std::to_string(i)});
        }
    }
    return "-1";
}

std::string bfs(std::vector<Permutation> base,std::vector<std::string> gens_recipes,std::function<bool(Permutation)> checker,std::string start_recipe=""){
    std::vector<Permutation> gens;
    for(int i=0;i<gens_recipes.size();i++){
        gens.push_back(bake(base,gens_recipes[i]));
    }
    std::string bad_ans = bfs(gens,checker,start_recipe);
    std::string og_ans;
    for(int i=0;i<bad_ans.size();i++){
        og_ans+=(gens_recipes[(bad_ans[i]-'0')]);
    }
    return og_ans;
}

int true_delta(int n, int delta){
    if(delta == 0){
        return n;
    } else if(delta > 0){
        return delta;
    } else {
        return n+delta;
    }
}

Permutation Prefix_by_delta(int n, int delta){
    return Prefix(n,true_delta(n, delta));
}

void find_recipes_for_evens_n2(){
    for(int n=6;n<=40;n+=2){
        for(int k=3;k<n-2;k+=2){
            std::vector<Permutation> base = {Prefix_by_delta(n,k),Prefix_by_delta(n,-2),Prefix_by_delta(n,0)};
            auto ans=bfs(base,{"0","12","21"},createAdjacentChecker(base[1]*base[2]),"");
            std::cout<<n<<" "<<k<<" ";
            if(ans=="-1"){
                std::cout<<"notfound";
            }
            else{
                std::cout<<ans<<" "<<bake({base[0],base[1],base[2]},ans).to_cycles();
            }
            std::cout<<std::endl;
        }
    }
}

void find_recipes_general(int delta, int k, std::function<bool(Permutation)> checker, int nmin=6, int nmax=30, int nstep=1){
        for(int n=nmin; n<=nmax; n+= nstep){
		    std::vector<Permutation> base = {Prefix_by_delta(n,k),Prefix_by_delta(n,delta),Prefix_by_delta(n,0)};
		    auto ans=bfs(base,{"0","12","21"},checker,"");
		    std::cout<<n<<" "<<k<<" ";
		    if(ans=="-1"){
			std::cout<<"notfound";
		    }
		    else{
                        auto res=bake({base[0],base[1],base[2]},ans).to_actual_cycles();
			std::cout<<ans<<" "<<res.size()<<" "<<(res[0].size()==n);
		    }
		    std::cout<<std::endl;	
	}
}

std::string find_recipes_general_parallel(int delta, int k, std::function<bool(Permutation)> checker, int nmin=6, int nmax=30, int nstep=1, std::string start=""){
        std::string latest_recipe;
        for(int n=nmin; n<=nmax; n+= nstep){
		    std::vector<Permutation> base = {Prefix_by_delta(n,k),Prefix_by_delta(n,delta),Prefix_by_delta(n,0)};
		    auto ans=parallel_bfs(base,{"0","1","2"},checker,start);
		    std::cout<<n<<" "<<k<<" ";
		    if(ans=="-1"){
			std::cout<<"notfound";
		    }
		    else{
                        latest_recipe = ans;
                        auto res=bake(base,ans).to_actual_cycles();
			std::cout<<ans<<" "<<res.size()<<" "<<(res[0].size()==n);
		    }
		    std::cout<<std::endl;	
	}
        return latest_recipe;
}

bool is_n_cycle(Permutation p){
    auto v = p.to_actual_cycles();
    bool res = v.size()==1 and v[0].size()==p.size();
    // if (res){
    //     std::cout << "I think this is a n-cycle: " << p.to_cycles() << std::endl;
    //     std::cout << "Number of cycles: " << v.size() << "\nSize of the first cycle: "<< v[0].size() << "\nSize of whole perm: " << p.size() << std::endl;
    // }
    return res;
}

void find_cycles_transpositions(int delta, std::string start_recipe=""){
    for(int n=7;n<=40;n+=4){
        for(int k=2;k<n-2;k++){
            std::cout<<"Trying r_"<<true_delta(n,k)<<" r_"<<true_delta(n,delta)<<" r_"<<true_delta(n,0)<<std::endl;
            std::vector<Permutation> base = {Prefix_by_delta(n,k),Prefix_by_delta(n,delta),Prefix_by_delta(n,0)};
            base.push_back(bake(base,"012"));
            auto cycle_recipe = bfs(base,is_n_cycle,start_recipe);
            if(cycle_recipe == "-1"){
                std::cout<<"cycle not found :(\n";
                continue;
            }
            auto closest_cycle = bake(base,cycle_recipe);
            std::cout<<"Cycle found:"<<cycle_recipe<<" "<<closest_cycle.to_cycles()<<std::endl;
            std::cout<<"N: "<<n<<"K: "<<k<<" 012:"<<bake(base,"012").to_cycles()<<std::endl;
            auto ans=bfs(base,createAdjacentChecker(closest_cycle),start_recipe);
            if(ans=="-1"){
                std::cout<<"transposition not found";
            }
            else{
                std::cout<<ans<<" "<<bake(base,ans).to_cycles();
            }
            std::cout<<std::endl;
        }
    }
}

std::string prefixReversalSequence(int k, int n) {
    if (k == 2) {
        return "0";
    } else if (k == n - 2) {
        return "0121";
    } else if (k % 2 == 0) {
        std::string prefix;
        for (int i = 0; i < k - 1; ++i) {
            prefix += (i % 2 == 0) ? '0' : '1';
        }
        return prefix + "212010";
    } else {
        std::string prefix;
        for (int i = 0; i < (k - 1); ++i) {
            prefix += (i % 2 == 0) ? '0' : '1';
        }
        return prefix + "02120" + "212010";
    }
}

void checkHypot(){
    for(int n=7;n<=40;n+=4){
        for(int k=2;k<n-2;k++){
            std::cout<<"Trying r_"<<true_delta(n,k)<<" r_"<<true_delta(n,-1)<<" r_"<<true_delta(n,0)<<std::endl;
            std::vector<Permutation> base = {Prefix_by_delta(n,k),Prefix_by_delta(n,-1),Prefix_by_delta(n,0)};
            auto tryy = bake(base,prefixReversalSequence(k,n));
            std::cout<<"N: "<<n<<" K: "<<k<<" "<<tryy.to_cycles()<<std::endl;
        }
    }
}

Permutation bake(std::vector<Permutation> generators, std::vector<int> recipe)
{
    auto ans = Permutation(generators[0].size());
    for (auto i : recipe)
    {
        ans = (ans * generators[i]);
    }
    return ans;
}

std::vector<int> bfs_vector(std::vector<Permutation> gens, std::function<bool(Permutation)> checker, std::vector<int> start_recipe = std::vector<int>(0,0)) {
    if (gens.empty()) {
        return {};
    }
    auto st = bake(gens, start_recipe);
    std::unordered_set<size_t> seen;
    std::queue<std::pair<Permutation, std::vector<int>>> q;
    
    std::vector<int> start_vec;
    for (int idx : start_recipe) {
        start_vec.push_back(idx);
    }
    q.push({st, start_vec});
    seen.insert(st.get_hash());
    if (checker(st)) {
        return start_vec;
    }
    while (!q.empty()) {
        auto v = q.front().first;
        auto rec = q.front().second;
        q.pop();
        if (checker(v)) {
            return rec;
        }
        
        for (int i = 0; i < gens.size(); ++i) {
            auto to = v * gens[i];
            if (seen.count(to.get_hash()) >= 1) {
                continue;
            }
            seen.insert(to.get_hash());
            auto new_rec = rec;
            new_rec.push_back(i);
            q.push({to, new_rec});
        }
    }
    return {};
}


// Multi-BFS function to find multiple targets
// std::vector<std::pair<Permutation, std::vector<int>>> multi_bfs(
//     std::vector<Permutation> base0,
//     std::vector<std::vector<int>> recipes0,
//     std::vector<std::function<bool(Permutation)>> checkers,
//     std::vector<int> start_recipe = {})
// {
//     std::vector<std::pair<Permutation, std::vector<int>>> results;
//     std::vector<Permutation> base_current = base0;
//     std::vector<std::vector<int>> recipes_current = recipes0;
//     bool first_run = true;
//     bool found_new = true;
//     while (found_new && !checkers.empty()) {
//         found_new = false;
//         auto composite_checker = [&](Permutation p) -> bool {
//             for (const auto& checker : checkers) {
//                 if (checker(p)) {
//                     return true;
//                 }
//             }
//             return false;
//         };
//
//         std::vector<int> recipe_found = bfs_vector(
//             base_current,
//             composite_checker,
//             first_run ? start_recipe : std::vector<int>(0,0)
//         );
//         std::cout<<"found recipe!!\n";
//         for (auto &i:recipe_found){
//             std::cout<<i<<" ";
//         }
//         std::cout<<std::endl;
//         first_run = false;
//
//         if (recipe_found.empty()) {
//             break;
//         }
//
//         Permutation found_perm = bake(base_current, recipe_found);
//         base_current.push_back(found_perm);
//         recipes_current.push_back(recipe_found);
//         results.push_back({found_perm, recipe_found});
//
//         auto it = std::remove_if(checkers.begin(), checkers.end(),
//             [&](const std::function<bool(Permutation)>& checker) {
//                 return checker(found_perm);
//             });
//         checkers.erase(it, checkers.end());
//
//         found_new = true;
//     }
//
//     return results;
// }
//
// Helper function to create checkers for prefix reversals
auto create_r_j_checker(int n, int j) {
    return [n, j](Permutation p) -> bool {
        if (p.size() != n) return false;
        auto v = p.get_vect();
        for (int i = 0; i < j; ++i) {
            if (v[i] != j - i) {
                return false;
            }
        }
        for (int i = j; i < n; ++i) {
            if (v[i] != i + 1) {
                return false;
            }
        }
        return true;
    };
}

std::vector<std::tuple<Permutation, std::vector<std::string>, std::string>> 
multi_bfs(
    std::vector<Permutation> base0,
    std::vector<std::string> base0_names,
    std::vector<std::pair<std::function<bool(Permutation)>, std::string>> checkers,
    std::vector<int> start_recipe = {})
{
    std::vector<std::tuple<Permutation, std::vector<std::string>, std::string>> results;
    std::vector<Permutation> base_current = base0;
    std::vector<std::string> base_names_current = base0_names;

    bool found_new = true;
    while (found_new && !checkers.empty()) {
        found_new = false;
        auto composite_checker = [&](Permutation p) -> bool {
            for (const auto& checker_pair : checkers) {
                if (checker_pair.first(p)) {
                    return true;
                }
            }
            return false;
        };
        
        std::vector<int> recipe_found = bfs_vector(
            base_current,
            composite_checker,
            start_recipe
        );
        start_recipe = {};  // Clear start_recipe after first use
        
        if (recipe_found.empty()) {
            break;
        }
        
        Permutation found_perm = bake(base_current, recipe_found);
        
        // Convert recipe to names using current name list
        std::vector<std::string> named_recipe;
        for (int idx : recipe_found) {
            if (idx < 0 || idx >= base_names_current.size()) {
                throw std::runtime_error("Invalid generator index in recipe");
            }
            named_recipe.push_back(base_names_current[idx]);
            std::cout<<base_names_current[idx]<<" ";
        }
        std::cout<<"= ";

        // Check which checkers are satisfied
        std::vector<std::string> satisfied_names;
        auto it = checkers.begin();
        while (it != checkers.end()) {
            if (it->first(found_perm)) {
                satisfied_names.push_back(it->second);
                std::cout<<it->second<<std::endl;
                it = checkers.erase(it);
            } else {
                ++it;
            }
        }
        
        if (satisfied_names.empty()) {
            break;
        }
        
        // Add found permutation to generators with first satisfied name
        std::string new_generator_name = satisfied_names[0];
        base_current.push_back(found_perm);
        base_names_current.push_back(new_generator_name);
        
        // Record results for all satisfied names
        for (const auto& name : satisfied_names) {
            results.push_back(std::make_tuple(found_perm, named_recipe, name));
        }
        
        found_new = true;
    }
    return results;
}

// Updated find_all_prefix_reversals with dynamic naming
void find_all_prefix_reversals(int n, int k, int delta) {
    Permutation r_k = Prefix_by_delta(n, k);
    Permutation r_delta_val = Prefix_by_delta(n, delta);
    Permutation r_n = Prefix_by_delta(n, 0);
    
    std::vector<Permutation> base0 = {r_k, r_delta_val, r_n};
    std::vector<std::string> base0_names = {
        "r_" + std::to_string(true_delta(n, k)),
        "r_" + std::to_string(true_delta(n, delta)),
        "r_" + std::to_string(n)
    };
    
    std::vector<std::pair<std::function<bool(Permutation)>, std::string>> checkers;
    for (int j = 2; j <= n; ++j) {
        if (j == true_delta(n, k) || j == true_delta(n, delta) || j == n) {
            continue;
        }
        checkers.push_back({create_r_j_checker(n, j), "r_" + std::to_string(j)});
    }
    
    auto results = multi_bfs(base0, base0_names, checkers);
    std::cout << "Found " << results.size() << " prefix reversals:\n";
    for (auto& result : results) {
        auto& [perm, recipe, name] = result;
        std::cout << "Found " << name << ": " << perm << " with recipe: ";
        for (const auto& gen_name : recipe) {
            std::cout << gen_name << " ";
        }
        std::cout << std::endl;
    }
}

// Updated find_all_prefix_reversals with dynamic naming
void find_all_prefix_reversals_mod(int n, int k, int delta) {
    Permutation r_k = Prefix_by_delta(n, k);
    Permutation r_delta_val = Prefix_by_delta(n, delta);
    Permutation r_n = Prefix_by_delta(n, 0);
    
    std::vector<Permutation> base0 = {r_k, r_delta_val, r_n,};
    std::vector<std::string> base0_names = {
        "r_" + std::to_string(true_delta(n, k)),
        "r_" + std::to_string(true_delta(n, delta)),
        "r_" + std::to_string(n)
    };
    
    std::vector<std::pair<std::function<bool(Permutation)>, std::string>> checkers;
    checkers.push_back({create_r_j_checker(n,k-2),"r_k-2"});
    checkers.push_back({create_r_j_checker(n,2),"r_2"});
    
    auto results = multi_bfs(base0, base0_names, checkers);
    std::cout << "Found " << results.size() << " prefix reversals:\n";
    for (auto& result : results) {
        auto& [perm, recipe, name] = result;
        std::cout << "Found " << name << ": " << perm << " with recipe: ";
        for (const auto& gen_name : recipe) {
            std::cout << gen_name << " ";
        }
        std::cout << std::endl;
    }
}

void find_good_trans(int n, int k) {
    Permutation r_k = Prefix_by_delta(n, k);
    Permutation r_k1 = Prefix_by_delta(n, k-1);
    Permutation r_n = Prefix_by_delta(n, 0);
    
    std::vector<Permutation> base0 = {r_k,r_k1, r_n};
    std::vector<std::string> base0_names = {
        "r_" + std::to_string(true_delta(n, k)),
        "r_" + std::to_string(true_delta(n, k-1)),
        "r_" + std::to_string(n)
    };
    
    std::vector<std::pair<std::function<bool(Permutation)>, std::string>> checkers = {{createAdjacentChecker(r_k*r_k1),"tr"}};
    auto results = multi_bfs(base0, base0_names, checkers);
    std::cout << "Found " << results.size() << " prefix reversals:\n";
    for (auto& result : results) {
        auto& [perm, recipe, name] = result;
        std::cout << "Found " << name << ": " << perm.to_cycles() << " with recipe: ";
        for (const auto& gen_name : recipe) {
            std::cout << gen_name << " ";
        }
        std::cout << std::endl;
    }
}

std::string repeat(int n, std::string r) {
    std::ostringstream os;
    for(int i = 0; i < n; i++)
        os << r;
    return os.str();
}

void find_good_recipes(int nmin, int nmax, int nmod, std::vector<int> n_rem, int kmod, std::vector<int> k_rem){
    // std::cout<<nmin<<" "<<nmax<<" "<<nmod<<" "<<kmod<<std::endl;
    // for(auto &i:n_rem) std::cout<<i; std::cout<<std::endl;
    // for(auto &i:k_rem) std::cout<<i; std::cout<<std::endl;
    std::vector<std::vector<int>> cool_recipes = {{1,0,2,1,0,2,0,2,0,1,2,0},{1,2,1,2,1,0,1,2,1,2},{1,0,2},{1,2,0,2},{1,0,1,0,2},{1,2,1,0,2},{1,0,2,0,2},{1,0,2,1,2},{0,2,1,0,2},{1,2,1,0,1,2},{2,1,2,1,0,2},{1,0,2,1,2,1,2},{1,0,1,0,2,0,2},{1,2,1,0,2,1,2},{1,2,1,0,2,0,2},{1,0,1,2,1,0,2},{1,0,1,0,1,2,0,2},{1,2,0,1,0,1,0,2},{1,2,1,0,1,0,2,1,2},{1,0,2,0,1,0,2,0,2},{1,0,1,0,2,0,2,0,2},{1,0,1,2,1,0,2,1,2},{1,0,2,0,1,2,0,2,0},{1,0,2,1,2,1,2,1,2},{1,0,1,2,1,2,1,0,2},{1,2,1,2,1,0,1,2,1,2},{2,1,0,1,2,1,0,1,0,2},{1,2,1,0,1,2,1,2,1,2},{1,0,1,0,1,2,1,0,1,2},{1,0,2,1,2,0,2,1,2,0},{1,0,1,0,1,2,1,0,1,0,2},{1,0,1,0,2,0,2,0,2,0,2},{1,0,2,1,2,1,2,1,2,1,2},{1,0,2,1,2,0,2,1,2,1,2},{1,2,1,0,2,1,2,1,2,0,2},{1,0,1,0,2,0,1,2,0,2,0,2},{1,0,2,1,0,2,0,2,0,1,2,0},{1,0,1,0,1,2,0,1,0,1,0,2},{1,0,1,0,1,0,2,1,0,2,0,1,2},{1,0,1,0,1,0,1,0,2,1,0,2,0,1,2},{1,0,1,0,1,0,1,2,1,0,1,2,0,1,2},{1,0,1,0,1,0,1,0,1,0,1,0,2,1,0,1,0,2,0,1,2}};

    for(int n=nmin; n<=nmax; n++){
        if (std::none_of(n_rem.cbegin(),n_rem.cend(), [r = n%nmod](int i){return r == i;})) continue;
        for(int k=n/2+1;k<n;k++){
            if (std::none_of(k_rem.cbegin(),k_rem.cend(),[r = k%kmod](int i){return r == i;})) continue;
            std::cout<<n<<" "<<k<<" ";
            Permutation r_k = Prefix_by_delta(n, k);
            Permutation r_k1 = Prefix_by_delta(n, k-1);
            Permutation r_n = Prefix_by_delta(n, 0);

            std::vector<Permutation> base0 = {r_k1,r_k, r_n};
            base0.push_back(bake(base0,"0201202"));
            std::vector<std::string> base0_names = {"0","1","2", "0201202"};        
            std::vector<std::pair<std::function<bool(Permutation)>, std::string>> checkers = {{createAdjacentChecker(r_k*r_k1),"tr"}};
            std::vector<std::tuple<Permutation, std::vector<std::string>, std::string>> results;
            

            if(k+3 == n){
                std::string my_try = "010"+repeat(((n-6)/4),"12");
                auto rev = bake(base0,my_try);
                if(checkers[0].first(rev)){
                    std::cout<<"My recipe for r_n-3 r_n worked! ";
                    std::vector<std::string> recs;
                    for (auto &i:my_try){
                        recs.push_back(std::string(1,i));
                    }
                    results.push_back(std::make_tuple(bake(base0,my_try),recs,"tr"));
                }
            }

            if(k+5 == n and n>=26){
                std::string my_try = "0201202"+repeat(((n-22)/4),"12");
                auto rev = bake(base0,my_try);
                if(checkers[0].first(rev)){
                    std::cout<<"My recipe for r_n-5 r_n worked! ";
                    std::vector<std::string> recs;
                    for (auto &i:my_try){
                        recs.push_back(std::string(1,i));
                    }
                    results.push_back(std::make_tuple(bake(base0,my_try),recs,"tr"));
                }
            }

            if(results.size() == 0){
                for (auto &rec:cool_recipes){
                    if (checkers[0].first(bake(base0,rec))){
                        std::vector<std::string> recs;
                        std::cout<<"Found cool recipe! ";
                        auto perm = bake(base0,rec);
                        //std::cout<<perm.to_cycles();
                        for(auto &i:rec) recs.push_back(base0_names[i]);
                        results.push_back(std::make_tuple(perm,recs,"tr"));
                        break;
                    }
                }
            }

            if (results.size() == 0){std::cout<<":(\n";continue;}
            //     results = multi_bfs(base0, base0_names, checkers);
            //
            for (auto& result : results) {
                auto& [perm, recipe, name] = result;
                for (const auto& gen_name : recipe) {
                    std::cout << gen_name;
                }
                std::cout << std::endl;
            }
        }
    }
}

// Example usage of multi_bfs
// void find_all_prefix_reversals(int n, int k, int delta) {
//     Permutation r_k = Prefix_by_delta(n, k);
//     Permutation r_delta_val = Prefix_by_delta(n, delta);
//     Permutation r_n = Prefix_by_delta(n, 0);
//
//     std::vector<Permutation> base0 = {r_k, r_delta_val, r_n};
//     std::vector<std::vector<int>> recipes0 = {{0}, {1}, {2}};
//
//     std::vector<std::function<bool(Permutation)>> checkers;
//     for (int j = 2; j <= n; ++j) {
//         if (j == k || j == true_delta(n, delta) || j == n) {
//             continue;
//         }
//         checkers.push_back(create_r_j_checker(n, j));
//     }
//
//     auto results = multi_bfs(base0, recipes0, checkers);
//     std::cout << "Found " << results.size() << " prefix reversals:\n";
//     for (auto& [perm, recipe] : results) {
//         std::cout << "Permutation: " << perm << " with recipe: ";
//         for(auto &i: recipe) std::cout<<i<<" "; std::cout<<std::endl;
//     }
// }

// int main(int argc, char *argv[]) {
//     if (argc != 7) {
//         std::cerr << "Usage: " << argv[0] << " <checker_type> <delta> <k> <nmin> <nmax> <nstep>\n";
//         return 1;
//     }
//
//     // Parse checker type
//     std::function<bool(Permutation)> checker;
//     if (std::string(argv[1]) == "0") {
// 	    std::cout<<"looking for an n-cycle"<<std::endl;
// 	checker = is_n_cycle;
//     } else if (std::string(argv[1]) == "1") {
// 	    std::cout<<"looking for (1 2)"<<std::endl;
//         checker = is_12;
//     } else {
//         std::cout << "Invalid checker type. Use 0 for is_n_cycle or 1 for is_12.\n";
//         return 1;
//     }
//
//     // Parse integer parameters
//     try {
//         int delta = std::stoi(argv[2]);
//         int k = std::stoi(argv[3]);
// 	std::cout<<"r_"<<k<<" r_n-"<<-delta<<" r_n"<<std::endl;
//         int nmin = std::stoi(argv[4]);
//         int nmax = std::stoi(argv[5]);
//         int nstep = std::stoi(argv[6]);
// 	std::cout<<"for n from "<<nmin<<" to "<<nmax<<" with step "<<nstep<<std::endl;
//         find_recipes_general_parallel(delta, k, checker, nmin, nmax, nstep);
//     } catch (const std::exception& e) {
//         std::cerr << "Error converting arguments to integers: " << e.what() << '\n';
//         return 1;
//     }
//
//     return 0;
// }
