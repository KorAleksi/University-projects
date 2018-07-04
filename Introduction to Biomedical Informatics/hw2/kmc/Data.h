
#pragma once
#include <iostream>
#include <vector>
#include <string>
using namespace std;
class Data
{
private:
	vector<string> experiements;
	vector<vector<double>> exp_levels_ribo;
	vector<vector<double>> exp_levels_nonribo;
	double max, min;


public:
	Data();
	~Data();
	void addExperiementName(const string name);
	void addExperessionLevels(const vector<vector<double>> matrix, const bool isRibo);
	string getExperiementName(const int index);
	double euclideanDistance(vector<double> a, vector<double> b);
	double euclideanDistance(int a, int b);
	vector<double> getGene(int ind);
	vector<double> getGene(int ind, const bool isRibo);
	void findMaxAndMin();
	bool isRibosomal(const int ind);
	int getRiboDataSize();
	int getNonRiboDataSize();
	double getMax();
	double getMin();
};


