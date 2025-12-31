import React, { useState } from "react";
import "./Call.css";


const Call = ({account, onCall}) => {
  const [invitee, setInvitee] = useState("");
  const [callType, setCallType] = useState(2); // 2: 视频呼叫, 1: 音频呼叫

  const handleCallTypeChange = (e) => {
    setCallType(Number(e.target.value));
  };

  const call = () => {
    if (!invitee) {
      alert("请输入账号ID");
      return;
    }
    if (account === invitee) {
      alert("不能呼叫自己");
      return;
    }
    try {
      onCall(invitee.trim(), callType);
    } catch (error) {
      console.error("call error: ", error);
    }
  };

  return (
    <div className="call-container">
      <div
        style={{
          flex: "auto",
          display: "flex",
          flexDirection: "column",
          padding: "0 10px",
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            padding: "10px 0",
            color: "#1f1f26",
          }}
        >
          <label>您的ID</label>
          <div style={{ marginLeft: "10px" }}>{account}</div>
        </div>

        <div className="search">
          <div className="call-input-box">
            <input
              className="input-search-user"
              type="text"
              value={invitee}
              maxLength={50}
              placeholder="请输入账号ID"
              onChange={(e) => setInvitee(e.target.value)}
            />
          </div>
          <div className="btn-search" onClick={call}>
            呼叫
          </div>
        </div>

        <div
          style={{
            display: "flex",
            flexDirection: "row",
            alignItems: "center",
            color: "#1f1f26",
            padding: "10px 0",
          }}
        >
          <div>呼叫类型</div>
          <div
            style={{
              marginLeft: "15px",
              display: "flex",
              flexDirection: "row",
              alignItems: "center",
            }}
          >
            <label
              style={{
                display: "flex",
                flexDirection: "row",
                alignItems: "center",
              }}
            >
              <input
                type="radio"
                value={2}
                checked={callType === 2}
                onChange={handleCallTypeChange}
              />
              <span style={{ marginLeft: "5px" }}>视频呼叫</span>
            </label>
            <label
              style={{
                marginLeft: "15px",
                display: "flex",
                flexDirection: "row",
                alignItems: "center",
              }}
            >
              <input
                type="radio"
                value={1}
                checked={callType === 1}
                onChange={handleCallTypeChange}
              />
              <span style={{ marginLeft: "5px" }}>音频呼叫</span>
            </label>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Call;