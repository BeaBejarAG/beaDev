@isTest(SeeAllData=false)
public with sharing class TestUtilities {
  static string ClassicEntProccess = 'Classic Entitlement';
  static string StandardEntProccess = 'Standard Entitlement';
  static string EssentialEntProccess = 'Essentials Entitlement';
  static string PremierEntProccess = 'Premier Entitlement';

  public static Account getAccount() {
    Account thisAccount = new Account();
    thisAccount.Name = 'Name-' + Crypto.getRandomInteger();
    return thisAccount;
  }

  public static Asset getAsset(Id accountId) {
    Asset thisAsset = new Asset();
    thisAsset.Name = 'Name-' + Crypto.getRandomInteger();
    thisAsset.AccountId = accountId;

    return thisAsset;
  }

  public static ProductRouting__c GetProductRouting(
    string product,
    string ProdNum
  ) {
    ProductRouting__c prc = new ProductRouting__c(
      Name = product,
      Classic_Entitlement_Process__c = GetSlaProccessID(ClassicEntProccess),
      Essential_Entitlement_Process__c = GetSlaProccessID(EssentialEntProccess),
      Standard_Entitlement_Process__c = GetSlaProccessID(StandardEntProccess),
      Premier_Entitlement_Process__c = GetSlaProccessID(PremierEntProccess),
      Related_Product_Range__c = product,
      Product_Division__c = 'SCS'
    );
    insert prc;

    Product_Number__c Pnumb = new Product_Number__c(
      name = ProdNum,
      Product_Routing__c = prc.id
    );

    insert Pnumb;

    return prc;
  }

  public static ServiceContract GetServiceContract(Account acc) {
    ServiceContract scc = new ServiceContract(
      AccountId = acc.id,
      Name = 'Name-' + Crypto.getRandomInteger(),
      StartDate = datetime.now().date() - 15,
      EndDate = datetime.now().addMonths(5).date(),
      SME_Contract_Status__c = 'Active'
    );

    insert scc;

    return scc;
  }

  public static Service_Contract_Lines__c GetServiceContractLines(
    ServiceContract Scc,
    string ProdNum
  ) {
    Service_Contract_Lines__c SCL = new Service_Contract_Lines__c(
      Name = 'Name-' + Crypto.getRandomInteger(),
      Start_Date__c = datetime.now().date() - 15,
      End_Date__c = datetime.now().addMonths(5).date(),
      Product_Number__c = decimal.valueOf(ProdNum),
      Line_Status__c = 'Active',
      Service_Contract__c = Scc.Id
    );

    insert SCL;
    return SCL;
  }

  public static Service_Contract_Lines__c GetServiceContractLinesCSP(
    ServiceContract Scc,
    string ProdNum,
    string PlanLevel
  ) {
    Service_Contract_Lines__c SCL = new Service_Contract_Lines__c(
      Name = 'Name-' + Crypto.getRandomInteger(),
      Start_Date__c = datetime.now().date() - 15,
      End_Date__c = datetime.now().addMonths(5).date(),
      Product_Number__c = 9999,
      Line_Status__c = 'Active',
      Service_Contract__c = Scc.Id,
      Plan_Type__c = 'Success Plan',
      Plan_Level__c = PlanLevel,
      Plan_Product_Number__c = ProdNum
    );
    insert SCL;

    return SCL;
  }

  private static id GetSlaProccessID(string Inname) {
    SlaProcess ProcID = [
      SELECT Id, NAME
      FROM Slaprocess
      WHERE name = :Inname AND IsVersionDefault = TRUE
    ];

    Entitlement_Process__c entproc = new Entitlement_Process__c(
      Name = Inname,
      Proccess_ID__c = ProcID.Id
    );

    insert entproc;

    return entproc.Id;
  }

  public static KCS_Level__c GetKCSLevel() {
    User newuser = new User();
    newuser = Internaladminuser();

    KCS_Level__c KCS = new KCS_Level__c();
    KCS.KCS_User__c = newuser.Id;
    KCS.Key_Field__c = 'Ready';

    insert KCS;

    return KCS;
  }

  public static User CreateUserComm() {
    User thisUser = new User();
    thisUser.Title = 'Mr';
    thisUser.FirstName = 'Roger';
    thisUser.LastName = 'Moore';
    thisUser.Email = 'RMoore@TheAccessGroup.com';
    thisUser.ProfileId = '00e58000000NgDx';

    return thisUser;
  }

  public static User internaladminuser() {
    User NewUser = new User(
      profileId = '00e58000000rpgN',
      Username = System.now().getTime() + 'InternalCase@test.com',
      Alias = 'RRTest',
      Email = 'Ryan.ReyonldsInternalCase@test.com',
      EmailEncodingKey = 'UTF-8',
      Title = 'Mr',
      Firstname = 'Ryan',
      Lastname = 'Reyonlds',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_GB',
      TimeZoneSidKey = 'Europe/London'
    );
    insert NewUser;

    return NewUser;
  }

  public static User createUser (String roleName,  String profileName,  String userAlias) {

    UserRole role = [SELECT Id FROM UserRole WHERE Name =: roleName LIMIT 1];
    Profile profile = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];

    User user = new User(
      Username = System.now().getTime() + 'test@user.com', 
      ProfileId = profile.Id, 
      UserRoleId = role.Id,
      Alias = userAlias, 
      Email = 'test123@test.com', 
      EmailEncodingKey = 'UTF-8', 
      Title = 'Mr',
      LastName = 'McTesty', 
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_GB',
      TimeZoneSidKey = 'Europe/London'
    );

    insert user;
    return user;
  }

  public static User createPortalUser (String portalProfileName, Id portalContactId, String userAlias) {

    Profile profile = [SELECT Id FROM Profile WHERE Name =: portalProfileName LIMIT 1];

    User user = new User(
      Username = System.now().getTime() + 'test@user.com', 
      ProfileId = profile.Id, 
      ContactId = portalContactId,
      Alias = userAlias, 
      Email = 'test123@test.com', 
      EmailEncodingKey = 'UTF-8', 
      Title = 'Mr',
      LastName = 'McTesty', 
      CommunityNickname = 'test12345' + System.now().getTime(), 
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_GB',
      TimeZoneSidKey = 'Europe/London'
    );

    insert user;
    return user;
  }

  public static Contact getContact() {
    Contact thisContact = new Contact();
    thisContact.FirstName = 'Chris';
    thisContact.LastName = 'Lewis';
    thisContact.Email = 'Chris.Lewis@accountech.co.uk';

    return thisContact;
  }

  public static Contact getContact(Account account) {
    Contact contact = getContact();
    contact.AccountId = account.id;

    return contact;
  }

  public static Case getCase() {
    Case thisCase = new Case();
    return thisCase;
  }

  public static CaseComment getCaseComment(Id parentId) {
    CaseComment thisCaseComment = new CaseComment();
    thisCaseComment.ParentId = parentId;

    return thisCaseComment;
  }

  public static Entitlement GetEntitlement(account AccountIdin) {
    Entitlement Ent = new Entitlement(
      Name = 'Classic Dimensions',
      Accountid = AccountIdin.id,
      StartDate = datetime.now().date() - 15,
      EndDate = datetime.now().addMonths(5).date(),
      AssociatedProductRange__c = 'Dimensions',
      SlaProcessId = [
        SELECT id, name, isVersionDefault
        FROM slaProcess
        WHERE
          isVersionDefault = TRUE
          AND isactive = TRUE
          AND name = 'Classic Entitlement'
        LIMIT 1
      ]
      .Id
    );

    insert ent;

    return ent;
  }

  public static Contract getContract(Id accountId) {
    Contract thisContract = new Contract();
    thisContract.AccountId = accountId;
    thisContract.ProductRange__c = 'Select HR';
    thisContract.PlanType__c = 'Standard';

    return thisContract;
  }

  public static Note getNote(Id parentId) {
    Note thisNote = new Note();
    thisNote.ParentId = parentId;
    thisNote.Title = 'Title-' + Crypto.getRandomInteger();

    return thisNote;
  }

  public static Product2 getProduct() {
    Product2 thisProduct = new Product2();
    thisProduct.Name = 'Name-' + Crypto.getRandomInteger();

    return thisProduct;
  }

  public static Knowledge__kav getArticleAsADraft(
    String title,
    String urlName
  ) {
    Knowledge__kav newArticle = new Knowledge__kav();
    newArticle.Title = title;
    newArticle.UrlName = urlName;
    return newArticle;
  }
}