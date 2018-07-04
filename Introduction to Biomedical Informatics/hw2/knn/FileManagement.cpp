#include "stdafx.h"
#include "FileManagement.h"
#include <fstream>
#include <string>
#include <sstream>
#include "Data.h"

using namespace std;

FileManagement::FileManagement()
{
}


FileManagement::~FileManagement()
{
}

//  
void FileManagement::readFile(Data & data)
{
	ifstream inFile;

	// Read experiement names
	inFile.open("experiments.txt"); // open stream
	string str, n, name_start, name_end;
	while (getline(inFile, str)) {
		stringstream ss;
		ss << str;
		ss >> n >> name_start >> name_end;
		data.addExperiementName(name_start + " " + name_end);
	}
	inFile.close();

	// read expression levels to Data object
	readData(data, "ribo-data.txt");
	readData(data, "nonribo-data.txt");
}

void FileManagement::readData(Data & data, const string file_name)
{
	bool isRibo = false; 
	int y = 2346;
	int x = 79;
	double exp_level;
	string line; // 
	vector<vector<double>> exp_matrix; // Is used for storing the expression data from input file.
	int i = 0; // iterator

	if (file_name == "ribo-data.txt") {
		isRibo = true;
		y = 121;
	}

	ifstream inFile;
	inFile.open(file_name);

	while (getline(inFile, line)) {
		vector<double> exp_vector;
		stringstream ss;
		ss << line;
		for (int j = 0; j < x; j++) {
			ss >> exp_level;
			exp_vector.push_back(exp_level);
		}
		exp_matrix.push_back(exp_vector);
		i++;
	}
	inFile.close();
	data.addExperessionLevels(exp_matrix, isRibo);
}