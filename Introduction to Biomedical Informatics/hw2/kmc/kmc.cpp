/*
kmc.cpp : Defines the entry point for the K Means console application.

Creator: Aleksi Artturi Korkee
Student ID: 12180067

- Uses nonribo-data.txt and ribo-data.txt (data is tab-delimited):
- 79 experiement conditions (Columns)
- 121 ribosomal genes + 2346 nonribosomal genes = 2467 genes total (Rows)
- Each element contains an expression level in given gene and condition.
- experiments.txt lists in which experiments each of the 79 columns corresponds.
- The names and short functional annotations for each gene are found in ribo-names.txt and nonribo-names.txt.
*/

#include "stdafx.h"
#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <random>
#include "Data.h"
#include "FileManagement.h"

using namespace std;


// initialize functions
vector<vector<double>> randomCenters(Data & data, int k);
vector<vector<int>> kmc(Data & data, int k, vector<vector<double>>& centers);
void random20Times(Data & data);
bool isStringInt(string & s, int & k);
vector<vector<double>> chooseCenters(Data & data, int k);
void crossValidation(Data & data, int k, double p);
bool end();
int main();


// Picks k number of starting centers randomly
vector<vector<double>> randomCenters(Data& data, int k) 
{
	// minimum and maximum indexes
	double min = 1;
	double max = data.getNonRiboDataSize() + data.getRiboDataSize();
	// used for generating random numbers
	random_device seeder;
	mt19937 engine(seeder());
	uniform_int_distribution <int> dist(min, max);

	vector<vector<double>> centers;
	vector<int> used_inds;
	int ind;
	string in_str;

	cout << "Generating " << k << " random index:\n";
	// Program chooses k different random indexes.
	for (int i = 0; i < k; i++) {
		while (true) {
			ind = dist(engine);
			if (find(used_inds.begin(), used_inds.end(), ind) == used_inds.end()) {
				break;
			}
		}
		// Same index cannot be entered more than once.
		used_inds.push_back(ind);
		centers.push_back(data.getGene(ind - 1));
		cout << ind << endl;
	}
	return centers;
}


// Checks if a string can be fully converted to integer
bool isStringInt(string& s, int& i)
{
	stringstream st;
	st << s;
	st >> i;
	if (s == to_string(i)) { return true; }
	return false;
}


// pick k number of centers from genes.
vector<vector<double>> chooseCenters(Data& data, int k) {

	vector<vector<double>> centers;
	vector<int> used_inds;
	int ind;
	string in_str;

	cout << "Choose " << k << " indexes from 1-2467 genes.\n(1-2346 nonribosomal and 2347-2467 ribosomal)\n";

	// Program asks user to input k number of genes as index numbers.
	for (int i = 0; i < k; i++) {
		// Asks input until a valid input is given
		while (true) {
			cout << "Gene " << i + 1 << endl;
			getline(cin, in_str);
			// Checks if given input is an integer.
			if (isStringInt(in_str, ind)) {
				if (ind >= 1 && ind <= 2467 && find(used_inds.begin(), used_inds.end(), ind) == used_inds.end()) {
					break;
				}
			}
			cout << "Invalid index. Try again.\n";
		}
		// Same index cannot be entered more than once.
		used_inds.push_back(ind);
		centers.push_back(data.getGene(ind - 1));
	}
	return centers;
}


// Prints the percentage of ribosomal genes in each cluster.
void outputClusters(Data& data, vector<vector<int>>& clusters, const int fileInd = 0) {
	int ribosomal;
	bool isRibosomal;
	int i, j;
	int gene;
	ofstream myFile;
	myFile.open("kmc_out/ribosomal_k" + to_string(clusters.size()) +"_i" + to_string(fileInd) + ".txt");

	for (i = 0; i < clusters.size(); i++) {
		ribosomal = 0;
		cout << "Ribosomal genes in cluster " << i + 1 << endl;
		myFile << "Ribosomal genes in cluster " << i + 1 << " :\n";
		// Sums the ribosomal genes found in current cluster.
		for (j = 0; j < clusters[i].size(); j++) {
			gene = clusters[i][j];
			isRibosomal = data.isRibosomal(gene);
			if (isRibosomal) {
				ribosomal++;
				myFile << gene + 1 - data.getNonRiboDataSize() << endl;
			}
		}
		myFile << endl;
		cout << ribosomal << "/" << clusters[i].size() << " (" << ((double)ribosomal / clusters[i].size() * 100) << "%)" << endl; // prints the percentage.
	}
	myFile.close();
}


// The K-means algorithm
// Assigns each datapoint to closest center to create clusters.
// Centers change each iteration to the center point of cluster.
// End iterations if distance between centers don't change or 50 iterations has passed.
vector<vector<int>> kmc(Data& data, int k, vector<vector<double>>& centers) 
{
	// initialize cluster matrixes
	vector<vector<int>> clusters = vector<vector<int>>(k);
	vector<vector<int>> lastClusters = vector<vector<int>>(k);
	vector<vector<int>> initClusters = vector<vector<int>>(k); // used to clear clusters from data
	// initialize centers
	vector<vector<double>> newCenters = vector<vector<double>>(k);
	vector<vector<double>> initCenters = vector<vector<double>>(k);
	
	vector<double> exp_level;

	pair<double, int> smallestDistToCluster; // has the distance to cluster and the index of that cluster
	double lastDist = numeric_limits<double>::max();
	double temp_Dist;
	//iterators
	int i, j, gene, c_num;
	int numOfGenes = data.getNonRiboDataSize() + data.getRiboDataSize();
	// make each element in matrixes accessible
	for (i = 0; i < k; i++) {
		clusters[i] = {};
		newCenters[i] = {};
		initCenters[i] = {};
		initClusters[i] = {};
	}

	cout << "Calculating kmc...\n";
	int iters = 50;
	// iterates 50 times or unitl clusters don't change.
	for (i = 0; i < iters; i++) {
		cout << (int)((double)i / (double)iters * 100) << "%\r";
		// assign genes to clusters.
		for (gene = 0; gene < numOfGenes; gene++) {
			// Smallest distance to clusters is first maximized.
			smallestDistToCluster = make_pair(numeric_limits<double>::max(),-1);
			exp_level = data.getGene(gene); // expression level of current gene.
			// calculates current genes distance to every cluster. 
			for (c_num = 0; c_num < k; c_num++) {
				temp_Dist = data.euclideanDistance(centers[c_num], exp_level);
				if (temp_Dist < smallestDistToCluster.first) {
					smallestDistToCluster = make_pair(temp_Dist, c_num);
				}
			}
			// pushes the gene to a cluster that it is closest to.
			clusters[smallestDistToCluster.second].push_back(gene);

			// calculate the new centers. We will take the mean of each gene in a cluster to get new centers.
			for (j = 0; j < 79; j++) {
				// If the gene is the first on assigned to the cluster, then add the exp levels to newCenters.
				if (newCenters[smallestDistToCluster.second].size() != 79) {
					newCenters[smallestDistToCluster.second] = exp_level;
					break;
				}
				// Add the current gene to a center of the cluster it is assigned to.
				newCenters[smallestDistToCluster.second][j] += exp_level[j];
				// If the current gene is the last one, divide the summed expression levels by the number of genes in that cluster
				// to get the new centers for each cluster.
				if(gene == numOfGenes-1){
					for (c_num = 0; c_num < k; c_num++) {
						newCenters[c_num][j] /= clusters[c_num].size();
					}
				}
			}
			
		}
		// save the centers and clusters from current iteration and clear them for the next iteration.
		centers = newCenters;
		newCenters = initCenters;
		lastClusters = clusters;
		clusters = initClusters;

		// check if the distance of clusters has changed.
		double dist = data.euclideanDistance(centers[0], centers[1]);
		if (dist == lastDist) { break; }
		else if (dist < lastDist) { lastDist = dist; }
	}
	cout << "100%\n\n";
	return lastClusters;
}

void random20Times(Data& data) {
	vector<vector<double>> centers;
	vector<vector<int>> clusters;
	int k = 2;
	for (int i = 0; i < 20; i++) {
		centers = randomCenters(data, k);
		// Calculates clusters  
		clusters = kmc(data, k, centers);
		outputClusters(data, clusters, i);
	}
}


int main()
{
	Data data;
	string in_str;
	string randOrChoose;
	int k;
	vector<vector<double>> centers;
	vector<vector<int>> clusters;
	FileManagement fm;

	cout << "HW2 - K-Means" << endl;
	cout << "Introduction to Biomedical Informatics" << endl;
	cout << "Aleksi Artturi Korkee" << endl;
	cout << "Student ID: 12180067";

	// Read data
	fm.readFile(data);
	fm.~FileManagement();

	// runs program until user wants to quit.
	while (true) {	
		// Asks if user wants to get starting centers randomly or choose them.
		while (true) {
			cout << "\n\nStarting point random(r) or choose(c): ";
			getline(cin, in_str);
			if (in_str == "r" || in_str == "c") { break; }
			cout << "Invalid input!\n";
		}
		randOrChoose = in_str;
		// Asks for k. Checks if it is integer
		while (true) {
			cout << "Choose k:";
			getline(cin, in_str);
			if (isStringInt(in_str,k)) {
				if (k >= 2) { break; }
			}
			cout << "Invalid input!\n";
		}
		// Gets centers randomly or user chooses them
		if (randOrChoose == "r") { centers = randomCenters(data, k); }
		else { centers = chooseCenters(data, k); }
		// Calculates clusters  
		clusters = kmc(data, k, centers);
		outputClusters(data,clusters);
		
		// Asks user if they want to run the program again
		cout << "Run again? y/n: ";
		getline(cin, in_str);
		while (in_str != "y" && in_str != "n") {
			cout << "Run again? y/n: ";
			getline(cin, in_str);
		}
		if (in_str == "y") { continue; }
		/* Uncomment to run 20 random clusterings
		cout << "Do you want to run tests with random starting points 20 times? y/n: ";
		getline(cin, in_str);
		while (in_str != "y" && in_str != "n") {
			cout << "Do you want to run tests with random starting points 20 times? y/n: ";
			getline(cin, in_str);
		}
		if (in_str == "y") { 
			random20Times(data); 
			break;
		}
		*/
		else { break; }
	}
	return 0;
}