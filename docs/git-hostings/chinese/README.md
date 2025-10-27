# 中国代码托管平台集成文档

本文档包含中国代码托管平台（如Gitee、Coding.net等）的集成指南、工作流和配置说明。

## 支持的平台

- [Gitee (码云)](https://gitee.com/)
- [Coding.net](https://coding.net/)
- [GitCode](https://gitcode.net/)
- [Gitea (自托管)](https://gitea.io/)
- [GitLink](https://www.gitlink.org.cn/)

## 环境要求

- Git 2.25.0 或更高版本
- Node.js 16.x 或更高版本
- Yarn 或 npm 包管理器
- 各平台API访问令牌

## 快速开始

### 1. 平台账号设置

#### Gitee
1. 注册 [Gitee](https://gitee.com/signup) 账号
2. 生成个人访问令牌：
   - 进入「设置」→「安全设置」→「私人令牌」
   - 创建新令牌，勾选 `projects` 和 `pull_requests` 权限

#### Coding.net
1. 注册 [Coding.net](https://coding.net/) 账号
2. 生成访问令牌：
   - 进入「个人设置」→「访问令牌」
   - 创建新令牌，选择 `project:read` 和 `project:write` 权限

### 2. 项目配置

#### 安装依赖
```bash
yarn add @katya/chinese-git-utils
# 或
npm install @katya/chinese-git-utils
```

#### 配置文件
在项目根目录创建 `.katya.chinese.json` 文件：

```json
{
  "platform": "gitee",
  "apiBaseUrl": "https://gitee.com/api/v5",
  "accessToken": "your-access-token",
  "repoOwner": "your-username",
  "repoName": "katya",
  "branch": "main",
  "autoMerge": true,
  "ciConfig": {
    "enabled": true,
    "platform": "gitee-actions",
    "configFile": ".gitee/workflows/ci.yml"
  }
}
```

## CI/CD 工作流

### Gitee Actions 配置
在 `.gitee/workflows/ci.yml` 中：

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18.x'
          
      - name: Install dependencies
        run: yarn install --frozen-lockfile
        
      - name: Run tests
        run: yarn test
        
      - name: Build
        run: yarn build
        
      - name: Deploy
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: yarn deploy
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

### 合规性检查

```yaml
- name: 合规性检查
  run: |
    # 检查代码中是否包含敏感信息
    if grep -r "password\|secret\|token" --include="*.{js,ts,json,env}" --exclude-dir={node_modules,.git} .; then
      echo "Error: 检测到敏感信息泄露风险"
      exit 1
    fi
    
    # 检查依赖安全漏洞
    yarn audit --level=high
```

## 发布管理

### 自动发布
在 `package.json` 中添加发布脚本：

```json
{
  "scripts": {
    "release": "standard-version && git push --follow-tags origin main"
  }
}
```

### 版本号规范
遵循 [语义化版本](https://semver.org/lang/zh-CN/)：
- `主版本号`：不兼容的 API 修改
- `次版本号`：向下兼容的功能性新增
- `修订号`：向下兼容的问题修正

## 包管理

### 发布到 npm 中国镜像
```bash
# 设置镜像源
yarn config set registry https://registry.npmmirror.com

# 登录
yarn login --registry=https://registry.npmmirror.com

# 发布
yarn publish
```

## 最佳实践

1. **分支策略**
   - `main`: 稳定版本
   - `develop`: 开发分支
   - `feature/*`: 功能分支
   - `release/*`: 预发布分支
   - `hotfix/*`: 热修复分支

2. **提交信息规范**
   ```
   <type>(<scope>): <subject>
   
   [optional body]
   
   [optional footer]
   ```
   
   **类型 (type)**
   - `feat`: 新功能
   - `fix`: 修复bug
   - `docs`: 文档更新
   - `style`: 代码格式
   - `refactor`: 代码重构
   - `perf`: 性能优化
   - `test`: 测试相关
   - `chore`: 构建过程或辅助工具的变动

## 常见问题

### 1. 认证失败
**问题**: 推送代码时提示认证失败  
**解决**: 
```bash
git config --global credential.helper store
# 下次推送时输入用户名和密码
```

### 2. 大文件上传
**问题**: 文件超过平台大小限制  
**解决**:
```bash
# 安装 git-lfs
git lfs install

# 跟踪大文件
git lfs track "*.zip"

# 提交 .gitattributes
git add .gitattributes
git commit -m "chore: track zip files with git-lfs"
```

### 3. 同步 GitHub 代码
```bash
# 添加 GitHub 远程仓库
git remote add github https://github.com/username/katya.git

# 推送到 GitHub
git push github main

# 从 GitHub 拉取更新
git pull github main
```

## 安全建议

1. 使用 SSH 密钥代替密码认证
2. 定期轮换访问令牌
3. 在 CI/CD 中使用加密的环境变量
4. 启用双因素认证(2FA)
5. 定期审计依赖项安全漏洞

## 贡献指南

1. Fork 项目仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 许可证

[Apache 2.0](LICENSE)

## 支持

如有问题，请提交 [Issue](https://gitee.com/your-username/katya/issues) 或联系维护者。
