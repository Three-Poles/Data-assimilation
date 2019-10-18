// iofsOpt.hpp
// Basic operators of ifstream and ofstream
// liufeng 2019/3/14

#include<fstream>

/*
**统计txt文件行数
*/
int CountLines(string filename)
{
	ifstream ReadFile;
	int n = 0;
	string tmp;
	ReadFile.open(filename, ios::in);//ios::in 表示以只读的方式读取文件  
	if (ReadFile.fail())//文件打开失败:返回0  
	{
		return 0;
	}
	else//文件存在  
	{
		while (getline(ReadFile, tmp, '\n'))
		{
			n++;
		}
		ReadFile.close();
		return n;
	}
}


/*
**复制txt文件
*/
void copyTxt(string srcFilename, string dstFilename)
{
	ifstream infile;
	ofstream outfile;
	string temp;
	infile.open(srcFilename, ios::in);
	outfile.open(dstFilename, ios::trunc | ios::out);
	if (infile.good())
	{
		while (!infile.eof())
		{
			getline(infile, temp, '\n');
			outfile << temp << '\n';
		}
	}
	infile.close();
	outfile.close();
 
}


/*
**清除txt文件
*/
void clearTxt(string filename)
{
	ofstream text;
	text.open(filename, ios::out | ios::trunc);//如果重新设置需要
	text.close();
}

/*
**修改指定行数据
*/
void ResetLine(string file,int line)
{	
	int total = CountLines(file);
	if (line > total || line < 1)
	{
		MessageBox(_T("修改超出配置文件行数范围"));
		return;
	}
	string bup = _T(".\\tmp.txt");//备份文件
	copyTxt(file,bup);
	ifstream rfile;
	ofstream wfile;
	rfile.open(bup,ios::in);
	wfile.open(file,ios::out|ios::trunc);
 
	string str;
	int i = 1;
	while (!rfile.eof())
	{		
		if (i == line)
		{
			CString strMFC;
			strMFC.Format(_T("%f %f %f\n"), m_pAssistCam, m_tAssistCam, m_zAssistCam);
			wfile << strMFC.GetBuffer(0);//写入修改内容
		}
		else
		{
			//rfile.getline()
			getline(rfile, str, '\n');
			wfile << str << '\n';
		}
		i++;
	}
	rfile.close();
	wfile.close();
}

/*
  **读取txt指定行数据存入string
  */
string readTxt(string filename, int line)
{
	//line行数限制 1 - lines
	ifstream text;
	text.open(filename, ios::in);
 
	vector<string> strVec;
	while (!text.eof())  //行0 - 行lines对应strvect[0] - strvect[lines]
	{
		string inbuf;
		getline(text, inbuf, '\n');
		strVec.push_back(inbuf);
	}
	return strVec[line - 1];
}