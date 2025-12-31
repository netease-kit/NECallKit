import "./Login.css";
import logo from "@/assets/logo.png";
import background from "@/assets/background.svg";

const Login = ({ account, onAccountChange, token, onTokenChange, onLogin, loading=false }) => {

  const login = () => {
    if (!account) {
      alert("账号不能为空!");
      return;
    }
    if (!token) {
      alert("Token不能为空!");
      return;
    }
    onLogin();
  };

  return (
    <div className="container">
      <img className="background-image" src={background} alt="background" />
      <div className="counter-warp">
        <div className="header-content">
          <img
            style={{ width: "212px", height: "27px" }}
            src={logo}
            alt="logo"
          />
        </div>
        <div className="box">
          <div className="list-item">
            <label className="list-item-label">账号ID</label>
            <input
              className="input-box"
              type="text"
              value={account}
              maxLength={50}
              placeholder="请输入账号ID"
              onChange={(e) => onAccountChange(e.target.value)}
            />
          </div>
          <div className="list-item" style={{ marginTop: "15px" }}>
            <label className="list-item-label">Token</label>
            <input
              className="input-box"
              type="text"
              value={token}
              maxLength={50}
              placeholder="请输入Token"
              onChange={(e) => onTokenChange(e.target.value)}
            />
          </div>
          <div className="login">
            <button className="loginBtn" onClick={login} disabled={loading}>
              登录
            </button>
          </div>
          <div style={{ marginTop: "30px", textAlign: "center" }}>
            <a
              href="https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7"
              style={{ color: "#007BFF" }}
              target="_blank"
              rel="noopener noreferrer"
            >
              如何获取云信账号与Token
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;