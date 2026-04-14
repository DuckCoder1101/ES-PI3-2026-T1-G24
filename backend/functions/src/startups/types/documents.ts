import { Timestamp } from 'firebase-admin/firestore';

export type StartupStage = 'nova' | 'em_operacao' | 'em_expansao';
export type QuestionVisibility = 'privada' | 'publica';

export interface Founder {
	name: string;
	role: string;
	equityPercent: number;
	bio?: string;
}

export interface ExternalMember {
	name: string;
	role: string;
	organization?: string;
}

export interface StartupDocument {
	name: string;
	stage: StartupStage;
	shortDescription: string;
	description: string;
	executiveSummary: string;
	capitalRaisedCents: number;
	totalTokensIssued: number;
	currentTokenPriceCents: number;
	founders: Founder[];
	externalMember: ExternalMember[];
	videos: string[];
	pitchDeckUrl?: string;
	coverImageUrl: string;
	tags: string[];
	createdAt?: Timestamp;
	updatedAt?: Timestamp;
}

export interface QuestionDocument {
	authorUId: string;
	text: string;
	visibility: QuestionVisibility;
	anwsers: QuestionAnwserDocument[];
	createdAt: Timestamp;
}

export interface QuestionAnwserDocument {
	authorId: string;
	text: string;
	createdAt: Timestamp;
}
