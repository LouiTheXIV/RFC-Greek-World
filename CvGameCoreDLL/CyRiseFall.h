#pragma once
/*
Author: bluepotato
*/
class CvRiseFall;
class CyRFCPlayer;
class CyRFCProvince;

class CyRiseFall {
	public:
		CyRiseFall();
		CyRiseFall(CvRiseFall* riseFallConst);

		CyRFCPlayer* getRFCPlayer(int civType);
		int getNumProvinces();
		CyRFCProvince* getRFCProvince(int province);
		CyRFCProvince* getRFCProvinceByName(std::wstring provinceName);
		void addProvince(std::wstring provinceName, int bottom, int left, int top, int right);
	protected:
		CvRiseFall* riseFall;
};
