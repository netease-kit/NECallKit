// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.user;

public class UserModel {
  private String accountId;
  private String token;
  private String mobile;
  private String name;
  private String avatar;

  public String getAccount() {
    return accountId;
  }

  public void setAccount(String accountId) {
    this.accountId = accountId;
  }

  public String getToken() {
    return token;
  }

  public void setToken(String token) {
    this.token = token;
  }

  public String getMobile() {
    return mobile;
  }

  public void setMobile(String mobile) {
    this.mobile = mobile;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getAvatar() {
    return avatar;
  }

  public void setAvatar(String avatar) {
    this.avatar = avatar;
  }

  @Override
  public String toString() {
    return "UserModel{"
        + "accountId='"
        + accountId
        + '\''
        + ", token='"
        + token
        + '\''
        + ", mobile='"
        + mobile
        + '\''
        + ", name='"
        + name
        + '\''
        + ", avatar='"
        + avatar
        + '\''
        + '}';
  }
}
