/*
knn.cpp : Defines the entry point for the K Means console application.

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
#include "FileManagement.h"
#include "Data.h"
#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <vector>
#include <deque>
#include <random>

using namespace std;

double calculateSensitivity(double tp, double fn);
double calculateSpecificity(double tn, double fp);
double calculateAccuracy(double tp, double tn, double total);
void outputResults(int k, double p, double sensitivity, double specificity, double accuracy);
string doubleToString(double val, int precision);
bool end();


// calculate sensitivity tp=true positives and fn=false negative
double calculateSensitivity(double tp, double fn) 
{
	return tp / (tp + fn);
}


// calculate specificity tn=true negatives and fn=false positives
double calculateSpecificity(double tn, double fp) 
{
	return tn / (tn + fp);
}


// calculate sensitivity tp=true positives and fn=true negative
double calculateAccuracy(double tp, double tn, double total) 
{
	return  (tp + tn) / total;
}


// Output results to console and save them to file
void outputResults(int k, double p, double sensitivity, double specificity, double accuracy) 
{
	// create lines for console output and saving to file
	string l1 = "k: " + to_string(k);
	string l2 = "p: " + doubleToString(p, 2);
	string l3 = "sensitivity: " + doubleToString(sensitivity, 2);
	string l4 = "specificity: " + doubleToString(specificity, 2);
	string l5 = "accuracy: " + doubleToString(accuracy, 2);

	// print the results to console
	cout<<"\n\n" << l1 << endl;
	cout << l2 << endl;
	cout << l3 << endl;
	cout << l4 << endl;
	cout << l5 << endl << endl << endl;

	// save the results to file
	ofstream myfile;
	myfile.open("knn.out");
	myfile << l1 << endl;
	myfile << l2 << endl;
	myfile << l3 << endl;
	myfile << l4 << endl;
	myfile << l5 << endl;
	myfile.close();
}


// converts double to string in wanted precision
string doubleToString(double val, int precision) 
{
	stringstream t;
	t.precision(precision);
	t << fixed << val;
	return t.str();
}


// Calculates k-nearest neighbour using training and test sets.
// Finds the k closest data points from training set.
// Predicts if test gene is ribosomal or nonribosomal based on the classes of the k nearest neighbours and parameter p.
// Returns a vector containing true positives, true negatives, false positives and false negatives. 
vector<int> knn(Data& data, const vector<int>& train, vector<int>& test, int k, double p) 
{
	int cur_iter = 1; // used for printing percentage of iterations completed.
	vector<int> result_vector = { 0,0,0,0 }; // stores TP,TN,FP,FN
	deque<pair<double, bool>> distances_and_classes; // vector for pairs of distances to k training data points and the class of what the data point has.
	pair<double, bool> temporary_pair; // pair of distances and a class for each iteration
	double current_distance; // Stores euclidean distance between one test and one training data point. 
	int positives; // number of ribosomal genes predicted.
	bool true_class;
	bool predicted_class;
	
	// used when finding a position for new distance/class pair in distances_and_classes vector.
	int lower_bound; 
	int upper_bound;
	int middle_point;

	// False positives are saved in following file.
	ofstream myFile;
	string filename = "knn_out/k" + to_string(k) + "_p" + to_string(p) + "FP.txt";
	myFile.open(filename, ios::app); // This allows to write in the end of a textfile.

	cout << "Calculating knn...\n";
	// Iterate through every test data point
	for (int test_data_point : test) 
	{
		cout << (int)(cur_iter / (double)(test.size()) * 100) << "%\r"; // print current progress
		//Iterate through every train data point
		for (int train_data_point : train) 
		{
			// calculates distance to new train data point.
			current_distance = data.euclideanDistance(test_data_point, train_data_point);
			// if k distances is not yet calculated then calculate new distance and add to vector.
			if (distances_and_classes.size() < k) 
			{
				temporary_pair = make_pair(current_distance, data.isRibosomal(train_data_point));
				distances_and_classes.push_back(temporary_pair);
				// if vector has k distances calculated, sort it from smallest distance to largest.
				if (distances_and_classes.size() == k) 
				{
					sort(distances_and_classes.begin(), distances_and_classes.end());
				}
			}
			else 
			{
				// more than k distances has calculated and added to vector.
				lower_bound = 0; // first position in distances_and_classes.
				upper_bound = k - 1; // last position in distances_and_classes.
				middle_point = k / 2; // middle position in distances_and_classes.
				
				// if calculated distance is larger than the largest stored distance then move to next training data point.
				if (current_distance >= distances_and_classes[upper_bound].first) 
				{
					continue;
				}
				// If calculated distance is smaller than any stored distance, add it to the front and remove the largest distance.
				if (current_distance <= distances_and_classes[lower_bound].first) 
				{
					temporary_pair = make_pair(current_distance, data.isRibosomal(train_data_point));
					distances_and_classes.pop_back();
					distances_and_classes.push_front(temporary_pair);
					continue;
				}
				// Finds where should the calculated distance be stored in the distances_and_classes vector and removes the largest element.
				while (true) 
				{
					// compares the calculated distance with distance in middle point and moves 
					// the upper and lower bound depending on the comparison
					if (current_distance <= distances_and_classes[middle_point].first) 
					{
						upper_bound = middle_point;
						middle_point = (lower_bound + upper_bound) / 2;
					}
					else 
					{
						lower_bound = middle_point;
						middle_point = (lower_bound + upper_bound) / 2;
					}
					// is the correct position for calculated distance found
					if (upper_bound - lower_bound <= 1) 
					{
						temporary_pair = make_pair(current_distance, data.isRibosomal(train_data_point));
						distances_and_classes.pop_back(); // largest element is removed.
						distances_and_classes.insert(distances_and_classes.begin() + upper_bound, temporary_pair);
						break;
					}
				}
			}
		}
		positives = 0;
		// calculate how many of the k nearest neighbours are ribosomal.
		for (auto &pair : distances_and_classes) 
		{
			positives += pair.second == true ? 1 : 0;
		}
		true_class = data.isRibosomal(test_data_point); // is the test gene ribosomal or nonribosomal
		predicted_class = ((double)positives / (double)k >= p); // predict if test gene is ribosomal
		// Compare prediction to the truth
		if (true_class) 
		{
			if (predicted_class) 
			{
				result_vector[0] += 1; // True posotive
			}
			else
			{
				result_vector[3] += 1; //False Negative
			}
		}
		else 
		{
			if (predicted_class) 
			{
				result_vector[2] += 1; // False positive
				myFile << test_data_point+1 << endl; // write to file if false positive
			}
			else 
			{
				result_vector[1] += 1; // true negative
			}
		}
		distances_and_classes.clear();
		cur_iter++;
	}
	cout << "\nTP: " << result_vector[0] << "\nTN: " << result_vector[1] << "\nFP: " << result_vector[2] << "\nFN: " << result_vector[3] << endl;
	return result_vector;
}


// Divides data to six groups. Runs k-nearest neighbour 6 times with different groups as test set and training set.
// One group will be test set and the rest will be training set.
// Let nonribo indexes be 0-2345 and ribo indexes 2346-2466 
void crossValidation(Data& data, int k, double p) 
{
	vector<int> indexes_nonribo; // 0-2345
	vector<int> indexes_ribo; // 2346-2466
	const int nonribo_size = data.getNonRiboDataSize();
	int nonribo_group_size = nonribo_size / 6; // nonribo genes in one group
	const int ribo_size = data.getRiboDataSize();
	int ribo_group_size = ribo_size / 6; // ribo genes in one group
	vector<vector<int>> groups_nonribo;
	vector<vector<int>> groups_ribo;
	vector<int> results{ 0,0,0,0 }; // vector for knn results (TP,TN,FP,FN)
	double acc(0), sen(0), spe(0); // accuracy, sensitivity and specificity
	vector<int> temporary_results; // temporary results from knn
	vector<int> test, train; // test and train set
	int i, j; // iterator

	// mix all nonribosomal genes in random order
	for (i = 0; i < nonribo_size; i++) 
	{
		indexes_nonribo.push_back(i); // add all nonribo indexes to vector
	}
	random_shuffle(indexes_nonribo.begin(), indexes_nonribo.end()); // random order
	// mix all ribosomal genes in random order	
	for (i = nonribo_size; i < ribo_size + nonribo_size; i++) 
	{
		indexes_ribo.push_back(i); // add all ribo indexes to vector
	}
	random_shuffle(indexes_ribo.begin(), indexes_ribo.end()); // random order

	// divides nonribo and ribo data into 6 different groups 
	for (i = 0; i < 6; i++) 
	{
		// add one sixth of the nonribo data into a nonribo group
		vector<int> temporary_group(indexes_nonribo.begin() + i * nonribo_group_size, indexes_nonribo.begin() + (i + 1) * nonribo_group_size);
		groups_nonribo.push_back(temporary_group);
		temporary_group.clear();
		
		// add one sixth of the ribo data into a ribo group.
		// the last ribo group has 21 genes instead of 20
		if (i == 5) 
		{
			temporary_group.assign(indexes_ribo.begin() + i * ribo_group_size, indexes_ribo.end());
		}
		else 
		{
			temporary_group.assign(indexes_ribo.begin() + i * ribo_group_size, indexes_ribo.begin() + (i + 1) * ribo_group_size);
		}
		groups_ribo.push_back(temporary_group);
	}

	// calculates knn 6 times with different groups as test and train sets
	for (int i = 0; i < 6; i++) 
	{
		test.clear();
		train.clear();
		test = groups_nonribo[i]; // index i will be chosen as test group in each iteration
		test.insert(test.end(), groups_ribo[i].begin(), groups_ribo[i].end()); // nonribo and ribo are joined in same test group
		// generate train group
		for (j = 0; j < 6; j++) 
		{
			if (i == j) { continue; } // same group cannot be in test and train groups
			train.insert(train.end(), groups_nonribo[j].begin(), groups_nonribo[j].end()); // add nonribos to train group
			train.insert(train.end(), groups_ribo[j].begin(), groups_ribo[j].end()); // add ribos to train group
		}
		// run knn to test and train sets
		temporary_results = knn(data, train, test, k, p);
		for (j = 0; j < 4; j++) 
		{
			results[j] += temporary_results[j]; // add this iteration's results to previous results
		}
	}
	// calculate sensitivity, accuracy and specificity
	sen = calculateSensitivity(results[0], results[3]);
	acc = calculateAccuracy(results[0], results[1], nonribo_size + ribo_size);
	spe = calculateSpecificity(results[1], results[2]);
	outputResults(k, p, sen, spe, acc); // print and save results to file
}


// Checks if string can be converted to integer
bool isStringInt(string& s, int& i) 
{
	stringstream st;
	st << s;
	st >> i;
	if (s == to_string(i)) { return true; }
	return false;
}

// Test with different K and p
void testDifferentK(Data& data) 
{
	crossValidation(data, 1, 0.05);
	crossValidation(data, 1, 0.25);
	crossValidation(data, 1, 0.5);
	crossValidation(data, 1, 0.75);
	crossValidation(data, 1, 0.9);
	crossValidation(data, 1, 1.0);

	crossValidation(data, 5, 0.05);
	crossValidation(data, 5, 0.25);
	crossValidation(data, 5, 0.5);
	crossValidation(data, 5, 0.75);
	crossValidation(data, 5, 0.9);
	crossValidation(data, 5, 1.0);

	crossValidation(data, 20, 0.05);
	crossValidation(data, 20, 0.25);
	crossValidation(data, 20, 0.5);
	crossValidation(data, 20, 0.75);
	crossValidation(data, 20, 0.9);
	crossValidation(data, 20, 1.0);

	crossValidation(data, 50, 0.05);
	crossValidation(data, 50, 0.25);
	crossValidation(data, 50, 0.5);
	crossValidation(data, 50, 0.75);
	crossValidation(data, 50, 0.9);
	crossValidation(data, 50, 1.0);

	crossValidation(data, 100, 0.05);
	crossValidation(data, 100, 0.25);
	crossValidation(data, 100, 0.5);
	crossValidation(data, 100, 0.75);
	crossValidation(data, 100, 0.9);
	crossValidation(data, 100, 1.0);
}

int main()
{
	int k;
	double p;
	string in_str;

	cout << "HW2 - K-Nearest Neighbors" << endl;
	cout << "Introduction to Biomedical Informatics" << endl;
	cout << "Aleksi Artturi Korkee" << endl;
	cout << "Student ID: 12180067\n\n";

	while (true) 
	{
		// Read k and p from input
		cout << "Input k: ";
		cin >> k;
		cout << "Input p: ";
		cin >> p;

		FileManagement fm;
		Data data;
		fm.readFile(data);
		fm.~FileManagement();

		crossValidation(data, k, p);
		//testDifferentK(data);

		while (true) 
		{
			cout << "Run again? y/n: ";
			cin >> in_str;
			if (in_str == "y" || in_str == "n") { break; }
		}
		if (in_str == "n") { break; }
	}
	return 0;
}