import './App.css'

const domains = [
  {
    name: '业务域',
    prefix: '带 qt 前缀',
    description: '面向具体业务线，内部复用多个职能域并编排组合',
    examples: 'qtrecurit（招聘）、qtcloud、qtclass',
  },
  {
    name: '职能域',
    prefix: '不带 qt 前缀',
    description: '可复用的职能能力层，被所有业务域调用',
    examples: 'human（人力资源）、asset（数字资产）、connect（沟通连接）',
  },
]

export default function App() {
  return (
    <main className="app">
      <section className="hero">
        <h1>量潮管理后台</h1>
        <p className="tagline">治理思想的平台化载体</p>
        <p className="intro">
          公司内部全面管理工具，覆盖各业务线与职能领域，按业务域与职能域分层组织。
        </p>
      </section>
      <section className="clouds">
        <h2>架构分层</h2>
        <div className="cloud-grid">
          {domains.map((domain) => (
            <div key={domain.name} className="cloud-card">
              <h3>{domain.name}</h3>
              <p className="domain">{domain.prefix}</p>
              <p className="description">{domain.description}</p>
              <p className="examples">{domain.examples}</p>
            </div>
          ))}
        </div>
      </section>
    </main>
  )
}
