#include "stdafx.h"
#include "Data.h"
#include <math.h>  


Data::Data()
{
}

Data::~Data()
{
}


// pushes name to experiements vector.
void Data::addExperiementName(string name)
{
	experiements.push_back(name);
}


// add expression levels to matrix
void Data::addExperessionLevels(const vector<vector<double>> matrix,const bool isRibo)
{
	if (isRibo) {
		exp_levels_ribo = matrix;
	}
	else {
		exp_levels_nonribo = matrix;
	}

}


// Uses index for determining if the wanted gene is ribosomal. 
bool Data::isRibosomal(const int ind) {
	if (ind < getNonRiboDataSize()) { return false; }
	else { return true; }
}


// returns the number of ribosomal genes in data
int Data::getRiboDataSize() {
	return (int)exp_levels_ribo.size();
}


// returns the number of nonribosomal genes in data
int Data::getNonRiboDataSize() {
	return (int)exp_levels_nonribo.size();
}



string Data::getExperiementName(const int index)
{
	return experiements[index];
}


// calculates the euclidean distance of two vectors
double Data::euclideanDistance(const vector<double> a, const vector<double> b)
{
	double sum = 0;
	size_t size = a.size();
	
	// goes trough every dimensions of vectors
	for (int i = 0; i < size; i++) {
		sum += pow(a[i] - b[i], 2);
	}
	return sqrt(sum);
}


// calculates the euclidean distance of two vectors using gene indexes as parameters
double Data::euclideanDistance(const int a, const int b) 
{
	vector<double> a_vec;
	vector<double> b_vec;
	int nonriboSize = getNonRiboDataSize();

	// Gets a vector from expression level data using indexes
	if (a < nonriboSize) { a_vec = exp_levels_nonribo[a]; }
	else { a_vec = exp_levels_ribo[a - nonriboSize]; }
	// Gets b vector from expression level data using indexes
	if (b < nonriboSize) { b_vec = exp_levels_nonribo[b]; }
	else { b_vec = exp_levels_ribo[b - nonriboSize]; }
	// calls the same function with different parameters
	return euclideanDistance(a_vec, b_vec);
}


// gets the expression vector from data using gene index.
vector<double> Data::getGene(int ind) 
{
	int nonriboSize = getNonRiboDataSize();
	// finds the gene in either ribo or nonribo data 
	if (ind < nonriboSize) { return exp_levels_nonribo[ind]; }
	else { return exp_levels_ribo[ind - nonriboSize]; }
}