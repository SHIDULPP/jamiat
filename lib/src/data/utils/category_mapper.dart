/// Maps UI filter labels to backend campaign category enums.
class CategoryMapper {
  CategoryMapper._();

  static const allLabel = 'All';

  static const uiToApi = <String, String>{
    allLabel: allLabel,
    'General Campaign': 'General Campaign',
    'General Funding': 'General Funding',
    'Zakath': 'Zakat',
    'Zakat': 'Zakat',
    'Orphan': 'Orphan',
    'Building Mosque': 'Building Mosque',
    'Medical Releif': 'Medical Relief',
    'Medical Relief': 'Medical Relief',
  };

  static const apiToUi = <String, String>{
    'General Campaign': 'General Campaign',
    'General Funding': 'General Funding',
    'Zakat': 'Zakat',
    'Orphan': 'Orphan',
    'Building Mosque': 'Building Mosque',
    'Medical Relief': 'Medical Relief',
  };

  static String toApi(String? uiLabel) {
    if (uiLabel == null || uiLabel.isEmpty || uiLabel == allLabel) {
      return allLabel;
    }
    return uiToApi[uiLabel] ?? uiLabel;
  }

  static String toUi(String? apiValue) {
    if (apiValue == null || apiValue.isEmpty) return 'General Campaign';
    return apiToUi[apiValue] ?? apiValue;
  }

  static const donateTabCategories = [
    allLabel,
    'General Campaign',
    'General Funding',
    'Zakat',
    'Orphan',
    'Building Mosque',
    'Medical Relief',
  ];
}
