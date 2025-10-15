class API {

  // Configurations
  static const String productMode             = 'STG'; // DEV, STG, PRD
  static const String baseDEV                 = 'stg-api-service.tkiero.app'; // TODO; Cambiar a API DEV
  static const String basePRD                 = 'stg-api-service.tkiero.app'; // TODO; Cambiar a API PRD
  static const String baseSTG                 = 'stg-api-service.tkiero.app';
  static const String versionApp              = '1.0.0';
  static const String baseURL                 = productMode == 'PRD' ? 'https://$basePRD/api' : productMode == 'STG' ? 'https://$baseSTG/api' : 'https://$baseDEV/api';
  static const String baseURLWebSocket        = productMode == 'PRD' ? 'https://$basePRD' : productMode == 'STG' ? 'https://$baseSTG' : 'https://$baseDEV';
  static const String urlClient               = productMode == 'PRD' ? 'https://client.tkiero.dev' : productMode == 'STG' ? 'https://client.tkiero.dev' : 'https://client.tkiero.dev'; // TODO; Cambiar a URLs por la configuración del entorno
  static const String termsAndConditions      = 'https://tkiero.app/Terms';

  // Bases
  static const String baseCatalog             = '$baseURL/catalogs';
  static const String basePOS                 = '$baseURL/pos';
  static const String baseWallet              = '$baseURL/wallet';
  static const String baseTiankii             = '$baseURL/tiankii';
  static const String baseACH                 = '$baseURL/ach';
  static const String baseAccount             = '$basePOS/account';

  // Catalog
  static const String catalog                 = '$baseCatalog/countries';
  static const String catalogState            = '$baseCatalog/states';
  static const String catalogMunicipality     = '$baseCatalog/municipalities';
  static const String catalogPaymentMethod    = '$baseCatalog/payment-methods';
  static const String catalogIdentyDocType    = '$baseCatalog/identity-document-types';
  static const String catalogBanks            = '$baseCatalog/banks';
  static const String catalogTypeBankAccount  = '$baseCatalog/types-bank-accounts';
  static const String catalogGenders          = '$baseCatalog/genders';

  // POS
  static const String supportCountries        = '$basePOS/supported-countries';
  static const String otpPhoneReq             = '$basePOS/otp-verification/phone-number/request';
  static const String otpPhoneVerify          = '$basePOS/otp-verification/phone-number/verify';
  static const String signUp                  = '$basePOS/signup';
  static const String signIn                  = '$basePOS/signin';
  static const String signInVerify            = '$basePOS/signin/verify';
  static const String posCategories           = '$basePOS/categories';
  static const String posUpload               = '$basePOS/files/upload';
  static const String posBusinesses           = '$basePOS/businesses';
  static const String refreshToken            = '$basePOS/refresh-token';
  static const String paymentMethod           = '$basePOS/payment-methods';
  static const String signOut                 = '$basePOS/signout';
  static const String transactions            = '$basePOS/business/transactions';
  static const String sessionInfo             = '$basePOS/session/info';

  //POS - Account
  static const String accountRepresentative   = '$baseAccount/representative';
  static const String updatePassword          = '$baseAccount/update-password';
  static const String requestOTPUpdatePhone   = '$baseAccount/request-change-phone-number';
  static const String updatePhone             = '$baseAccount/verify-request-change-phone-number';
  static const String resetPassword           = '$baseAccount/request/reset-password';
  static const String verifyResetPassword     = '$baseAccount/verify/request/reset-password';

  // Wallet
  static const String balance                 = '$baseWallet/balance';
  static const String deposit                 = '$baseWallet/deposit';
  static const String generate_invoice        = '$baseWallet/generate_invoice';

  // Tiankii
  static const String tiankiiChivoInReq       = '$baseTiankii/chivo/invoice/request';
  static const String tiankiiChivoChgPayM     = '$baseTiankii/chivo/invoice/change-payment-method';
  static const String tiankiiChivoInStatus    = '$baseTiankii/chivo/invoice/status';

  // ACH
  static const String limits                  = '$baseACH/limits';
  static const String transactionFee          = '$baseACH/transaction/fees';

  // WebSocket
  String webSocketContection({required String token, required String username}) => '$baseURLWebSocket?token=$token';

  // Endpoints querys
  String getIdentityDocumentTypes({required int idCountry}) => '$catalogIdentyDocType?country=$idCountry';
  String sendPhoto({required String uploadType, required int id}) => '$posUpload?uploadType=$uploadType&id=$id';
  String createBankAccount() => '$posBusinesses/bank-accounts';
  String getBankAccounts({required int idBusiness}) => '$posBusinesses/$idBusiness/bank-accounts?status=true';
  String bankAccountById({required int idBusiness, required int idAccount}) => '$posBusinesses/$idBusiness/bank-accounts/$idAccount';
  String putBankAccount({required int idAccount}) => '$posBusinesses/bank-accounts/$idAccount';
  String getBankByCountry({required int idCountry}) => '$catalogBanks?country=$idCountry';
  String deleteBankAccount({required int idBusiness, required int idAccount}) => '$posBusinesses/$idBusiness/bank-accounts/$idAccount';
  String postPaymentMethod() => paymentMethod;
  String getPaymentMethod({required String country, String page = '1', String limit = '10'}) => '$paymentMethod?country=$country&page=$page&limit=%limit';
  String putPaymentMethod({required int id}) => '$paymentMethod/$id/change-status';
  String getStatusChivoQR({required String invoiceId}) => '$tiankiiChivoInStatus?invoice_id=$invoiceId';
  String getTodayTransactions() {
  final DateTime now = DateTime.now();
  final DateTime firstDate = DateTime(2024, 1, 1); 

  final String formattedStartDate = '${firstDate.year}-${firstDate.month.toString().padLeft(2, '0')}-${firstDate.day.toString().padLeft(2, '0')}';
  final String formattedEndDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return '$transactions'
        '?startDate=$formattedStartDate'
        '&endDate=$formattedEndDate'
        '&page=1'
        '&limit=15';
  }
  String getTransactionHistory({required String startDate, required String endDate, String? transactionType, bool? floatingTransactions, String? page = '1', String? limit = '15'}) {
    String url = '$transactions'
        '?startDate=$startDate'
        '&endDate=$endDate'
        '&page=$page'
        '&limit=$limit';
    if (transactionType != null && transactionType.isNotEmpty) {
      url += '&transactionType=$transactionType';
    }
    if (floatingTransactions == true) {
      url += '&floatingTransactions=true';
    }
    return url;
  }
  String setNoteTransaction({required String idTransaction}) => '$transactions/$idTransaction';
  String getACHLimits({required String countryId, required String currency}) => '$limits?country=$countryId&currency=$currency&status=true&page=1&limit=10';
  String getACHTransactionFee({required String limitid, required String amount}) => '$transactionFee?limitId=$limitid&amount=$amount';
  String patchRepresentative({required int id}) => '$accountRepresentative/$id';
}