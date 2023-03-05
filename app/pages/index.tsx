import type { NextPage } from 'next'
import { useEffect, useState } from 'react';

import { useCeramicContext } from '../context';
import { Profile } from '../types';

import Head from 'next/head'

import Post from "../components/post.component"
import styles from "../styles/Home.module.scss"

const Home: NextPage = () => {  
  const clients = useCeramicContext()
  const { ceramic, composeClient } = clients

  const [profile, setProfile] = useState<Profile[] | []>([])

  const getProfile = async () => {
    if (ceramic.did !== undefined) {
      const res = await composeClient.executeQuery(`
        query {
          basicProfileIndex(last:100){
            edges{
              node{
                id
                name
                username
                description
                gender
                emoji
              }
            }
          }
        }
      `);
      const profiles: Profile[] = []
      res.data.basicProfileIndex.edges.map(profile => {
        if (profile.node) {
          profiles.push({
            id: profile.node.id,
            name: profile.node.name,
            username: profile.node.username,
            gender: profile.node.gender,
            emoji: profile.node.emoji,
          })
        }
      })
    setProfile(profiles);
    }
  }

  useEffect(() => {
    getProfile()
  }, [])

  return (
    <div className = "content">
      <div className={styles.postContainer}>
        {profile?.map(prof => (
          <p>Name: {prof.name}</p>
        ))}
      </div>
    </div>
  );
}

export default Home