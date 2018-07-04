#pragma once
#include "Data.h"
#include <string>

class FileManagement
{
public:
	FileManagement();
	~FileManagement();
	void readFile(Data& data);
	void readData(Data& data, string file_name);
};

