import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Apuntes y ejemplos 📖',
    description: (
      <>
        Documentación completa de los temas de Seguridad Informática (SI) de 2º SMR, con apuntes y ejemplos prácticos.
      </>
    ),
  },
  {
    title: 'Ejercicios prácticos ✍️',
    description: (
      <>
        Ejercicios prácticos para reforzar los conceptos aprendidos en cada tema, con soluciones y explicaciones detalladas.
      </>
    ),
  },
  {
    title: 'Vídeos explicativos 🎥',
    description: (
      <>
        Vídeos explicativos para cada tema, que facilitan la comprensión de los conceptos y su aplicación práctica.
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
