// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import SDWebImage
import SnapKit
import UIKit

// MARK: - Layout constants

private let kAvatarSize: CGFloat = 60.0
private let kAvatarCornerRadius: CGFloat = 7.0
private let kAvatarLeading: CGFloat = 16.0
private let kNameFontSize: CGFloat = 18.0
private let kSubtitleFontSize: CGFloat = 12.0
private let kTextLeadingOffset: CGFloat = 12.0
private let kButtonSize: CGFloat = 36.0
private let kAcceptButtonTrailing: CGFloat = 16.0
private let kRejectToAcceptSpacing: CGFloat = 22.0
private let kNameTopOffset: CGFloat = 10.0
private let kSubtitleBottomOffset: CGFloat = 10.0

// MARK: - NEIncomingCallBannerViewController

class NEIncomingCallBannerViewController: UIViewController {

  // MARK: - Public callbacks

  var onAccept: (() -> Void)?
  var onReject: (() -> Void)?
  var onBodyTap: (() -> Void)?

  // MARK: - Private properties

  private let callerId: String
  private let displayName: String
  private let avatarUrl: String?
  private let callType: Int

  // MARK: - UI components

  private lazy var avatarImageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = kAvatarCornerRadius
    iv.layer.masksToBounds = true
    iv.contentMode = .scaleAspectFill
    return iv
  }()

  private lazy var nameLabel: UILabel = {
    let lbl = UILabel()
    lbl.textColor = .white
    lbl.font = UIFont.boldSystemFont(ofSize: kNameFontSize)
    lbl.lineBreakMode = .byTruncatingTail
    lbl.numberOfLines = 1
    return lbl
  }()

  private lazy var subtitleLabel: UILabel = {
    let lbl = UILabel()
    lbl.textColor = UIColor(red: 0xC5 / 255.0, green: 0xCC / 255.0, blue: 0xDB / 255.0, alpha: 1.0)
    lbl.font = UIFont.boldSystemFont(ofSize: kSubtitleFontSize)
    return lbl
  }()

  private lazy var acceptButton: UIButton = {
    let btn = UIButton(type: .custom)
    let imageName = callType == 2 ? "call_accept_video" : "call_accept"
    btn.setBackgroundImage(bundleImage(named: imageName), for: .normal)
    btn.accessibilityLabel = callType == 2 ? "接听视频通话" : "接听"
    return btn
  }()

  private lazy var rejectButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setBackgroundImage(bundleImage(named: "icon_hangup"), for: .normal)
    btn.accessibilityLabel = "拒绝"
    return btn
  }()

  // MARK: - Init

  init(callerId: String, displayName: String, avatarUrl: String?, callType: Int) {
    self.callerId = callerId
    self.displayName = displayName
    self.avatarUrl = avatarUrl
    self.callType = callType
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError() }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 0x22 / 255.0, green: 0x26 / 255.0, blue: 0x2E / 255.0, alpha: 1.0)
    view.layer.cornerRadius = 10.0
    view.layer.masksToBounds = true
    setupSubviews()
    setupConstraints()
    setupInteractions()
    configureContent()
  }

  // MARK: - Layout

  private func setupSubviews() {
    view.addSubview(avatarImageView)
    view.addSubview(nameLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(rejectButton)
    view.addSubview(acceptButton)
  }

  private func setupConstraints() {
    avatarImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(kAvatarLeading)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(kAvatarSize)
    }

    acceptButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(kAcceptButtonTrailing)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(kButtonSize)
    }

    rejectButton.snp.makeConstraints { make in
      make.trailing.equalTo(acceptButton.snp.leading).offset(-kRejectToAcceptSpacing)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(kButtonSize)
    }

    nameLabel.snp.makeConstraints { make in
      make.top.equalTo(avatarImageView.snp.top).offset(kNameTopOffset)
      make.leading.equalTo(avatarImageView.snp.trailing).offset(kTextLeadingOffset)
      make.trailing.equalTo(rejectButton.snp.leading).offset(-kTextLeadingOffset)
    }

    subtitleLabel.snp.makeConstraints { make in
      make.leading.equalTo(avatarImageView.snp.trailing).offset(kTextLeadingOffset)
      make.bottom.equalTo(avatarImageView.snp.bottom).inset(kSubtitleBottomOffset)
    }
  }

  // MARK: - Content

  private func configureContent() {
    let placeholder = bundleImage(named: "icon_default_user")
    if let urlStr = avatarUrl, !urlStr.isEmpty, let url = URL(string: urlStr) {
      avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
    } else {
      avatarImageView.image = placeholder
    }

    nameLabel.text = displayName.isEmpty ? callerId : displayName

    switch callType {
    case 1:
      subtitleLabel.text = "邀请你进行语音通话"
    case 2:
      subtitleLabel.text = "邀请你进行视频通话"
    default:
      subtitleLabel.text = "邀请你进行语音通话"
    }
  }

  // MARK: - Interactions

  private func setupInteractions() {
    acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
    rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
    let tap = UITapGestureRecognizer(target: self, action: #selector(bodyTapped(_:)))
    view.addGestureRecognizer(tap)
  }

  @objc private func acceptTapped() {
    NEFLTCallUIKitLog.infoLog("NEIncomingCallBannerVC", desc: "bannerAcceptTapped")
    onAccept?()
  }

  @objc private func rejectTapped() {
    NEFLTCallUIKitLog.infoLog("NEIncomingCallBannerVC", desc: "bannerRejectTapped")
    onReject?()
  }

  @objc private func bodyTapped(_ gesture: UITapGestureRecognizer) {
    let point = gesture.location(in: view)
    if acceptButton.frame.contains(point) || rejectButton.frame.contains(point) { return }
    NEFLTCallUIKitLog.infoLog("NEIncomingCallBannerVC", desc: "bannerBodyTapped")
    onBodyTap?()
  }

  // MARK: - Helpers

  private func bundleImage(named name: String) -> UIImage? {
    let bundle = Bundle(for: type(of: self))
    if let img = UIImage(named: name, in: bundle, compatibleWith: nil) { return img }
    if let bundleURL = bundle.url(forResource: "NECallKitBundle", withExtension: "bundle"),
       let resourceBundle = Bundle(url: bundleURL),
       let img = UIImage(named: name, in: resourceBundle, compatibleWith: nil) { return img }
    return UIImage(named: name)
  }
}
