//
//  StringResources.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/11.
//

struct StringResources {
    // button
    static let add = "추가"
    static let cancel = "취소"
    static let confirm = "확인"
    static let complete = "완료"
    static let search = "검색"
    static let member = "멤버"
    static let team = "팀"
    static let follower = "팔로워"
    static let following = "팔로잉"
    static let message = "메시지"
    static let update = "수정"
    static let delete = "삭제"
    static let report = "신고"
    static let block = "차단"
    static let unblock = "차단 해제"
    
    // navigation
    static let sportSelectNavigationTitle = "스포츠 종목 추가"
    static let postCreateNavigationTitle = "새 게시물"
    static let postUpdateNavigationTitle = "게시물 수정"
    static let teamProfileCreateNavigationTitle = "새 팀 프로필"
    static let profileUpdateNavigationTitle = "프로필 편집"
    static let accountInfoNavigationTitle = "계정"
    static let infoNavigationTitle = "정보"
    static let settingsNavigationTitle = "설정"
    static let contactNavigationTitle = "문의"
    
    // login / join
    static let login = "로그인"
    static let join = "가입하기"
    static let forgotPassword = "비밀번호를 잊으셨나요?"
    static let emailTitle = "이메일 주소 입력"
    static let emailMessage = "입력한 이메일 주소로 인증코드가 전송됩니다."
    static let emailForNewPwdMessage = "비밀번호를 변경할 이메일을 입력해주세요.\n입력한 이메일 주소로 인증코드가 전송됩니다"
    static let authCodeTitle = "인증코드 입력"
    static let authCodeMessage = "주소로 전송된\n인증코드를 입력하세요."
    static let resendAuthCode = "인증코드 재전송"
    static let passwordTitle = "비밀번호 생성"
    static let usernameTitle = "사용자이름 생성"
    static let sportSelectTitle = "스포츠 선택"
    static let sportSelectMessage = "즐기는 스포츠를 1개이상 선택해주세요."
    static let sportSelectAlertMessage = "즐기시는 스포츠 추가 없이 회원가입 하시겠습니까?\n(추후에 프로필 편집을 통해 추가가 가능합니다)"
    static let joinFailAlertTitle = "회원가입 실패"
    static let joinFailAlertMessage = "회원가입에 실패하였습니다. 잠시후 다시 시도해 주세요."
    static let termsAgreeTitle = "약관 동의"
    static let termsAgreeMessage = "회원가입을 계속 진행하기 위해 약관을 동의해주세요"
    static let tosAgreeButton = "이용약관(필수)"
    static let privacyPolicyAgreeButton = "개인정보 처리방침(필수)"
    static let allTermsAgreeButton = "전체동의"
    static let termsDetailButton = "자세히 알아보기"
    static let loginInfoSaveTitle = "로그인 정보 저장"
    static let loginInfoSaveMessage = "님의 로그인 정보가 저장되므로 해당 기기에서는\n로그인 정보를 입력하지 않아도 됩니다."
    static let save = "저장"
    static let saveLater = "나중에하기"
    
    // location
    static let changeLocation = "지역 변경하기"
    static let deleteLocation = "지역 삭제"
    static let confirmToDeleteLocation = "를 삭제하시겠습니까?"
    static let confirmToSetLocation = "으로 지역을 설정하시겠습니까?"
    static let locationPermissionSettingTitle = "위치권한 설정"
    static let locationPermissionSettingMessage = "위치권한을 설정에서 허용해주세요"
    static let failedToGetAddress = "주소를 가져오는데 실패하였습니다."
    
    // sport
    static let failedToGetSportList = "스포츠 리스트를 가져오는데 실패하였습니다."
    
    // profile
    static let addProfilePhoto = "사진 추가"
    static let teamProfileCreateButton = "팀 프로필 생성"
    static let profileUpdateButton = "프로필 편집"
    static let teamProfileLimitAlertTitle = "팀 프로필 개수 제한"
    static let teamProfileLimitAlertMessage = "팀 프로필은 한 계정당 최대 10개까지만 생성 가능합니다."
    static let followButton = "팔로우"
    static let unfollowButton = "팔로우 취소"
    static let createProfileButton = "생성"
    static let reportUserAlertTitle = "사용자 신고하기"
    static let reportUserAlertMessage = "이 사용자를 \"부적절한 컨텐츠를 포함\"한 사유로 신고하시겠습니까?"
    static let blockUserAlertTitle = "사용자 차단하기"
    static let blockUserAlertMessage = "이 사용자를 차단하시겠습니까?"
    static let blockUserSuccessMessgae = "(이)가 차단되었습니다"
    
    // post
    static let setCurrentLocationMessage = "운동을 즐기시는\n지역을 설정해주세요."
    static let setCurrentLocation = "지역 설정하기"
    static let noPostInCurrentLocation = "주변 지역에 게시물이 없습니다."
    static let noMorePost = "게시물이 더이상 없습니다."
    static let createPostAlertTitle = "게시물 작성"
    static let createdPostAlertMessage = "지역을 설정해야 게시물 작성을 할 수 있습니다."
    static let upload = "게시"
    static let videoLengthLimitAlertTitle = "영상 길이 제한"
    static let videoLenthLimitAlertMessage = "영상 길이는 30초 이하로 제한됩니다"
    static let mediaCountLimitAlertTitle = "게시물 사진/영상 개수 제한"
    static let mediaCountLimitAlertMessage = "게시물의 사진/영상 개수는 최대 10개입니다"
    static let deletedPostMessage = "삭제된 게시물입니다"
    static let reportPostAlertTitle = "게시물 신고하기"
    static let reportPostAlertMessage = "이 게시물을 부적절한 게시물로 신고하시겠습니까?"
    
    // settings
    static let deleteTeamProfileButton = "팀프로필 삭제"
    static let deleteAccountButton = "계정삭제"
    static let tos = "이용약관"
    static let privacyPolicy = "개인정보 처리방침"
    static let locationTos = "위치기반서비스 이용약관"
    static let account = "계정"
    static let info = "정보"
    static let questions = "문의"
//    static let contactEmailMessage = "문의사항은 ymb3264@naver.com으로 문의주시기 바랍니다."
    static let logoutButton = "로그아웃"
    
    // stream chat
    static let deleteChannelAlertTitle = "채팅방 영구적으로 삭제"
    static let deleteChannelAlertMessage = "채팅방을 영구적으로 삭제하시면 상대방도 이 채팅방을 더 이상 볼 수 없게됩니다."
    static let leaveTeamChannelAlertTitle = "채팅방 나가기"
    static let leaveTeamChannelAlertMessage = "팀을 언팔로우 하시면 채팅방에서 자동으로 나가집니다."
    static let noChannelMessage = "채팅방이 없습니다"
    
    // error
    static let emailValidationError = "이메일 형식을 확인해주세요"
    static let loginError = "이메일 또는 비밀번호를 확인해주세요"
    static let wrongAuthCodeError = "인증번호가 틀립니다."
    static let failedToSendAuthCode = "인증번호 전송에 실패하였습니다.\n다시 시도해주세요."
    static let passwordValidationError = "비밀번호가 유효하지 않습니다."
    static let wrongPasswordForCheck = "비밀번호가 다릅니다."
    static let usernameValidationError = "사용자 이름에는 영어 대/소문자, 숫자,\n밑줄(_) 및 마침표(.)만 사용할 수 있습니다."
    static let existingUsernameError = "이미 사용중인 사용자이름입니다."
    static let failedToGetProfileInfo = "프로필정보를 가져오는데 실패하였습니다."
    static let failedToGetUserPost = "게시물을 가져오는데 실패하였습니다."
    
    // placeholder
    static let findLocationPlaceholder = "동명(읍, 면)으로 검색해주세요 (ex. 서초동)"
    static let hostPlaceholder = "(생성자)"
    static let emailPlaceholder = "이메일"
    static let passwordPlaceholder = "비밀번호"
    static let passwordForCheckPlaceholder = "비밀번호 확인"
    static let authCodePlaceholder = "인증코드"
    static let postCreateContentPlaceholder = "내용입력(첫째줄은 메인에 표시됩니다.)"
    static let addMediaPlaceholder = "사진 및 영상 추가"
    static let postCreatePreviewPlaceholder = "미리보기\n(터치 시 상세화면으로 이동)"
    static let sportPlaceholder = "운동종목"
    static let locationPlaceholder = "지역"
    static let teamProfileCreateContentPlaceholder = "팀 정보(소개)"
    static let teamUsernamePlaceholder = "팀 사용자 명"
    static let teamNamePlaceholder = "팀 명"
    static let updateProfileContentPlaceholder = "소개"
    static let namePlaceholder = "이름"
    
    // info
    static let postCreateMediaDeleteInfo = "스포츠 관련 사진/영상이 아닐경우 게시물이 삭제될 수 있습니다."
    static let postCreateSportInfo = "· 필수 입력칸입니다.\n· 해당 게시물을 나타내는 운동종목을 추가해보세요.\n· 여러종목이 선택가능하며, 없는 종목은 적어서 추가할 수 있습니다."
    static let postCreateLocationInfo = "· 필수 입력칸입니다.\n· 운동을 즐긴 지역을 추가해보세요.\n· 추가된 지역 주변으로 게시물이 노출됩니다."
    static let postCreateMediaInfo = "· 영상 길이는 30초 이하로 제한됩니다.\n· 게시물의 사진/영상 개수는 최대 10개입니다."
    static let postUpdateMediaInfo = "게시물의 사진/영상은 수정할 수 없습니다."
    static let teamNameInfo = "· 필수 입력값입니다.\n· 팀명은 알파벳, 숫자 이외에도 자유롭게 작성가능합니다.\n· 팀 프로필 생성시 자동 생성되는 팀 채팅방 이름이 작성된 팀명으로 설정됩니다."
    static let sportInfo = "· 프로필에 즐기는 운동을 추가해보세요.\n· 여러종목이 선택가능하며, 없는 종목은 적어서 추가할 수 있습니다."
    static let locationInfo = "· 운동을 주로 즐기는 지역을 추가해보세요."
    
    // common alert
    static let deleteFormTitle = "작성내용 삭제"
    static let deleteFormMessage = "작성중인 내용이 삭제됩니다"
    static let requiredFormAlertMessage = "필수 입력칸을 작성 완료해 주세요"
    static let reportSuccessMessgae = "신고가 정상적으로 접수되었습니다"
    
    // etc
    static let today = "오늘"
    static let seeMore = "더보기"
    
    // api
    static let tosUrl = "https://moare.kr/info/tos"
    static let privacyPolicyUrl = "https://moare.kr/info/privacy_policy"
    static let locationTosUrl = "https://moare.kr/info/location_tos"
}
